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
echo
echo rfriends for RaspberryPi bullseye $ver
echo
# =========================================
dir=$(cd $(dirname $0);pwd)
user=`whoami`
# -----------------------------------------
#sudo apt update && sudo apt upgrade -y
sudo apt -y install exim4
# -----------------------------------------
# .vimrcを設定する
# -----------------------------------------
sudo mv -n .vimrc .vimrc.org
sudo cp -p $dir/vimrc .vimrc
sudo chmod 644 .vimrc
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
sudo raspi-config nonint do_boot_wait 0
sudo raspi-config nonint do_memory_split 16
# -----------------------------------------
# ディレクトリ作成
# -----------------------------------------
mkdir -p /home/$user/tmp
mkdir -p /home/$user/smbdir/usr2
# =========================================
# rfriends3のインストール
# =========================================
cd  ~/
sudo apt install git
git clone https://github.com/rfriends/rfriends_ubuntu.git
cd rfriends_ubuntu
sh rfriends3_ubuntu.sh
# -----------------------------------------
# rc.localを設定する
# -----------------------------------------
grep rfriends /etc/rc.local > /dev/null
if [ $? = 1 ]; then
  sudo cp -n /etc/rc.local /etc/rc.local.org
  cat $dir/rc.local | sudo tee -a /etc/rc.local
fi
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
else echo "already exist"
fi
# =========================================
# システムの軽量化
# =========================================
sh $dir/lighter_weight.sh
# =========================================
# 作成日
# =========================================
sudo touch /boot/rf3info
#
echo finished
exit 0
# -----------------------------------------
