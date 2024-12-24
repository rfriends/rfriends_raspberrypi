#!/bin/sh
# =========================================
# raspios setup
# =========================================
# 2021/02/15
# 1.60 2021/10/26 add pulseaudio
# 1.90 2023/07/28 rfriends3
# 3.0.0 2023/10/30 renew
# 3.2.2 2024/12/25
ver=3.2.2
# =========================================
echo
echo rfriends_raspberrypi $ver for RaspberryPi $os
echo start `date`
echo
# =========================================
os=`cat /etc/os-release | grep VERSION_CODENAME= | sed s/VERSION_CODENAME=//`
if [ $os = 'bookworm' ]; then
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
sudo systemctl stop dphys-swapfile
sudo sed -i "/^CONF_SWAPSIZE/cCONF_SWAPSIZE=256" /etc/dphys-swapfile
sudo systemctl enable dphys-swapfile
# -----------------------------------------
# swappiness
# -----------------------------------------
sudo sed -i "/^vm.swappiness/d" /etc/sysctl.conf
sudo sed -i '$ avm.swappiness = 1' /etc/sysctl.conf
# =========================================
# rfriends3,samba,lighttpdのインストール
# =========================================
echo exec_step2
cd  $homedir
sudo apt-get install git
git clone https://github.com/rfriends/rfriends_ubuntu.git
cd rfriends_ubuntu
sh rfriends3_ubuntu.sh
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
tmpfs /var/tmp tmpfs defaults,size=16m,noatime,mode=1777 0 0
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
# -----------------------------------------
# new sh
sed -e sdir $dir/$rc.skel > $dir/$rfsh
sudo cp -f $dir/$rfsh /usr/local/bin/$rfsh
sudo chmod +x /usr/local/bin/$rfsh
# -------------------------------
# 以前の形式のものがあった場合
grep "/home/rpi/rfriends3/rfriends3_boot.sh" /etc/rc.local > /dev/null
if [ $? = 0 ]; then
  sudo mv -f /etc/rc.local /etc/rc.local.org
fi
# -------------------------------
# /etc/rc.localをローカルに保存
if [ -e /etc/rc.local ]; then
  cat /etc/rc.local > $dir/rc.local
else
cat << EOF $dir/rc.local
#!/bin/sh -e
# rfriends
sh /usr/local/bin/$rfsh
exit 0
EOF
fi
# -------------------------------
# exit 0 追加
grep "exit 0" $dir/rc.local > /dev/null
if [ $? != 0 ]; then
  sed '$a exit 0' $dir/rc.local
fi
# -------------------------------
grep "/usr/local/bin/$rfsh" $dir/rc.local > /dev/null
if [ $? != 0 ]; then
  sed "/exit 0/i sh /usr/local/bin/$rfsh" $dir/rc.local
fi
# -------------------------------
sudo cp -f $dir/rc.local /etc/rc.local
sudo chown root:root /etc/rc.local
sudo chmod +x /etc/rc.local
# -----------------------------------------
# /etc/ssh/sshd_configを設定する
# -----------------------------------------
if [ -e /etc/ssh/sshd_config ]; then
  sed -i "/^#ClientAliveInterval/c ClientAliveInterval 60" /etc/ssh/sshd_config
  sed -i "/^#ClientAliveCountMax/c ClientAliveCountMax 3"  /etc/ssh/sshd_config
fi
# =========================================
# システムの軽量化
# =========================================
echo exec_step4
sudo systemctl disable dbus
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
# 終了
# =========================================
echo exec_step5
#sudo apt-get autoremove
# =========================================
# 作成日
# =========================================
sudo touch /boot/rf3info
#
echo exec_step6
echo end `date`
echo finished
exit 0
# -----------------------------------------
