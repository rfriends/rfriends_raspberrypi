#!/bin/sh
# =========================================
# raspios setup
# =========================================
# 2021/02/15
# 1.60 2021/10/26 add pulseaudio
# 1.90 2023/07/28 rfriends3
# 3.0.0 2023/10/30 renew
# 3.2.2 2024/12/25
# 3.3.0 2025/01/25 install from rfriends3_core
# 3.3.1 2025/02/06 fstab 16M->64M
# 3.3.2 2025/05/14 mod
# 3.4.0 2025/10/06 trixie (仮)
ver=3.4.0
# =========================================
echo
echo rfriends_raspberrypi $ver for RaspberryPi $os
echo start `date`
echo

# =========================================
os=`cat /etc/os-release | grep VERSION_CODENAME= | sed s/VERSION_CODENAME=//`
if [ $os = 'trixie' ]; then
 boot=/boot/firmware
 rc=rc.local12
 lighter=lighter_weight12
elif [ $os = 'bookworm' ]; then
 boot=/boot/firmware
 rc=rc.local12
 lighter=lighter_weight12
else
 boot=/boot
 rc=rc.local11
 lighter=lighter_weight11
fi

if [ -z $HOME ]; then
  homedir=`sh -c 'cd && pwd'`
else
  homedir=$HOME
fi

dir=$(cd $(dirname $0);pwd)
conf=`pwd`/conf
user=`whoami`
sdir=s%rfriendshomedir%${homedir}%g
susr=s%rfriendsuser%$user%g
# -----------------------------------------
echo exec_step1
sudo apt-get update && sudo apt-get upgrade -y
sudo apt-get -y install exim4
#
# wifi power management off
sudo iw dev wlan0 set power_save off
# -----------------------------------------
# localeを設定する
#
sudo mv -n /etc/default/locale /etc/default/locale.org
sudo cp -p $conf/locale /etc/default/locale
sudo chmod 644 /etc/default/locale
# -----------------------------------------
# ジャーナル
#Storage=none
sudo mv -n /etc/systemd/journald.conf /etc/systemd/journald.conf.org
sudo cp -p $conf/journald.conf /etc/systemd
sudo chmod 644 /etc/systemd/journald.conf
sudo chown root:root /etc/systemd/journald.conf
# -----------------------------------------
# console
# -----------------------------------------
if [ ! -e /etc/default/console-setup ]; then
cat <<EOF | sudo tee /etc/default/console-setup > /dev/null
# CONFIGURATION FILE FOR SETUPCON
# Consult the console-setup(5) manual page.
ACTIVE_CONSOLES="/dev/tty[1-6]"
CHARMAP="UTF-8"
CODESET="guess"
FONTFACE="VGA"
FONTSIZE="16x32"
VIDEOMODE=
# The following is an example how to use a braille font
# FONT='lat9w-08.psf.gz brl-8x8.psf'
EOF
fi
# -----------------------------------------
# swap
# -----------------------------------------
if [ $os = 'bullseye' ]; then
 sudo systemctl stop dphys-swapfile
 sudo sed -i "/^CONF_SWAPSIZE/c CONF_SWAPSIZE=512" /etc/dphys-swapfile
 sudo systemctl enable dphys-swapfile
fi
# -----------------------------------------
# swappiness
# -----------------------------------------
sudo sed -i "/^vm.swappiness/d" /etc/sysctl.conf
sudo sed -i '$ avm.swappiness = 1' /etc/sysctl.conf
# =========================================
# rfriends3,samba,lighttpdのインストール
# =========================================
echo exec_step2
sudo apt-get install git
cd  $homedir
rm -rf rfriends3_core
git clone https://github.com/rfriends/rfriends3_core.git
if [ $? != 0 ]; then
  echo クローンに失敗しました。
  echo 少し時間をおいて再度実行してください。
  exit 1
fi
cd rfriends3_core
if [ $os = 'trixie' ]; then
 sh install_debian_apache2.sh
else
 sh install_debian.sh
fi
# -----------------------------------------
# crontab
# /var/spool/cron/crontabs/rpi
crontab $conf/crontab
# -----------------------------------------
# テンポラリ領域をtmpfs（Ramdisk上）に設定する
# -----------------------------------------
echo exec_step3
mkdir -p $homedir/tmp
#
grep rfriends /etc/fstab > /dev/null
if [ $? != 0 ]; then
cat <<EOF | sudo tee -a /etc/fstab > /dev/null
#
# rfriends
#
# mount ramdisk /tmp,/var/tmp,/var/log
tmpfs /tmp     tmpfs defaults,size=64m,noatime,mode=1777 0 0
tmpfs /var/tmp tmpfs defaults,size=64m,noatime,mode=1777 0 0
tmpfs /var/log tmpfs defaults,size=32m,noatime,mode=0755 0 0
#
# mount ramdisk /home/$user/tmp
tmpfs $homedir/tmp tmpfs defaults,size=320m,noatime,mode=0777 0 0
#
# mount usb memory $homedir/smbdir
#
#UUID= $homedir/smbdir   ext4    defaults    0   0
#PARTUUID= $homedir/smbdir/usbdisk exfat-fuse  nofail,defaults,nonempty,noatime,uid=1000,gid=1000 0 0
#
EOF
else 
  echo "already exist"
fi
# =========================================
# rc.localを設定する
# =========================================
rfsh=rfriends-rclocal.sh
cd $dir
echo $dir
# -----------------------------------------
# new sh
cp -f $rc.skel $rfsh
sed -i $sdir $rfsh
sed -i $susr $rfsh
sudo cp -f $rfsh /usr/local/bin/$rfsh
sudo chmod +x /usr/local/bin/$rfsh
# -------------------------------
# 以前の形式のものがあった場合
grep "/home/rpi/rfriends3/rfriends3_boot.sh" /etc/rc.local > /dev/null
if [ $? = 0 ]; then
  sudo mv -f /etc/rc.local /etc/rc.local.org
  echo 以前の形式の/etc/rc.localを削除しました
fi
# -------------------------------
# /etc/rc.localをローカルに保存
if [ -e /etc/rc.local ]; then
  cat /etc/rc.local > rc.local
  echo /etc/rc.localをローカルに保存しました
else
cat << EOF > rc.local
#!/bin/sh -e
# rfriends
sh /usr/local/bin/$rfsh
exit 0
EOF
  echo rc.localをローカルに作成しました
fi
# -------------------------------
# exit 0 追加
grep "exit 0" rc.local > /dev/null
if [ $? != 0 ]; then
  sed '$a exit 0' rc.local
  echo rc.localにexit 0を追加しました
fi
# -------------------------------
grep "/usr/local/bin/$rfsh" rc.local > /dev/null
if [ $? != 0 ]; then
  sed -i "/exit 0/i sh /usr/local/bin/$rfsh" rc.local
  echo rc.localに新しいshを追加しました
fi
# -------------------------------
sudo cp -f rc.local /etc/rc.local
sudo chown root:root /etc/rc.local
sudo chmod +x /etc/rc.local
# -----------------------------------------
# /etc/ssh/sshd_configを設定する
# -----------------------------------------
if [ -e /etc/ssh/sshd_config ]; then
  sudo sed -i "/^#ClientAliveInterval/c ClientAliveInterval 60" /etc/ssh/sshd_config
  sudo sed -i "/^#ClientAliveCountMax/c ClientAliveCountMax 3"  /etc/ssh/sshd_config
fi
# =========================================
# システムの軽量化
# =========================================
echo exec_step4
#sudo systemctl disable dbus
sudo systemctl disable triggerhappy
#sudo systemctl disable alsa-utils
#sudo systemctl disable lightdm
#sudo systemctl disable motd
#sudo systemctl disable plymouth
#
# CAMERAモジュール
sudo sed -i '/^camera_auto_detect/s/^/#/' $boot/config.txt 
#
sh $dir/$lighter.sh
# =========================================
# 作成日
# =========================================
echo exec_step5
sudo rm $boot/rfriends.ip
sudo rm $boot/rfriends.wlan
#sudo touch $boot/rf3info
sudo touch $boot/rfriends.create
# =========================================
# 終了
# =========================================
echo exec_step6
echo end `date`
echo finished
#
#sudo apt-get autoremove
export HISTFILESIZE=0
export HISTSIZE=0 
exit 0
# -----------------------------------------
