#!/bin/sh
# =========================================
# raspios setup
# =========================================
# 2021/02/15
# 1.60 2021/10/26 add pulseaudio
# 1.90 2023/07/28 rfriends3
# 3.0.0 2023/10/30 renew
# 3.2.0 2024/12/22
ver=3.2.0
# =========================================
os=`cat /etc/os-release | grep VERSION_CODENAME= | sed s/VERSION_CODENAME=//`
if [ $os = 'bookwarm' ]; then
 boot=/boot/firmware
 rc=rc.local12
 lighter=lighter_weight12
else
 boot=/boot
 rc=rc.local
 lighter=lighter_weight
fi
# =========================================
echo
echo rfriends_raspberrypi $ver for RaspberryPi $os
echo
# =========================================
dir=$(cd $(dirname $0);pwd)
user=`whoami`
# -----------------------------------------
#sudo apt-get update && sudo apt-get upgrade -y
sudo apt-get -y install exim4
#
# wifi power management off
sudo iwconfig wlan0 power off
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
# -----------------------------------------
# .vimrcを設定する
# -----------------------------------------
mv -n .vimrc .vimrc.org
cat <<EOF > .vimrc
set encoding=utf-8
set fileencodings=iso-2022-jp,euc-jp,sjis,utf-8
set fileformats=unix,dos,mac
EOF
chmod 644 .vimrc
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
# -----------------------------------------
# ディレクトリ作成
# -----------------------------------------
mkdir -p /home/$user/tmp
mkdir -p /home/$user/smbdir/usr2
# =========================================
# rfriends3のインストール
# =========================================
cd  ~/
sudo apt-get install git
git clone https://github.com/rfriends/rfriends_ubuntu.git
cd rfriends_ubuntu
sh rfriends3_ubuntu.sh
# -----------------------------------------
# テンポラリ領域をtmpfs（Ramdisk上）に設定する
# -----------------------------------------
grep rfriends /etc/fstab > /dev/null
if [ $? = 1 ]; then
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
tmpfs /home/$user/tmp tmpfs defaults,size=320m,noatime,mode=0777 0 0
#
# mount usb memory /home/$user/smbdir
#
#UUID= /home/$user/smbdir   ext4    defaults    0   0
#PARTUUID= /home/$user/smbdir/usbdisk exfat-fuse  nofail,defaults,nonempty,noatime,uid=1000,gid=1000 0 0
#
EOF
else 
  echo "already exist"
fi
# =========================================
# rc.localを設定する
# =========================================
grep rfriends /etc/rc.local > /dev/null
if [ $? = 1 ]; then
  sudo cp -n /etc/rc.local /etc/rc.local.org
  sed -i 's/rfriendsuser/$user/g' $dir/$rc
  cat $dir/$rc | sudo tee -a /etc/rc.local > /dev/null
fi
# =========================================
# システムの軽量化
# =========================================
sudo systemctl disable dbus
sudo systemctl disable triggerhappy
#sudo systemctl disable alsa-utils
sudo systemctl disable lightdm
sudo systemctl disable motd
sudo systemctl disable plymouth
#
# CAMERAモジュール
sed -i '/^camera_auto_detect/s/^/#/' $boot/config.txt 
#
sh $dir/$lighter.sh
# =========================================
# 終了
# =========================================
#sudo apt-get autoremove
# =========================================
# 作成日
# =========================================
sudo touch /boot/rf3info
#
echo finished
exit 0
# -----------------------------------------
