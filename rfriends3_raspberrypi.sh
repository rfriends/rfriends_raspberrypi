#!/bin/sh
#
# raspios setup
#
# 2021/02/15
# 1.60 2021/10/26 add pulseaudio
# 1.70 2021/11/01 
# 1.80 2022/05/09 
# 1.90 2023/07/28 rfriends3
# 3.0.0 2023/10/30 renew
# 3.0.1 2023/11/12
# 3.1.0 2024/10/10
# 3.2.0 2024/12/22
ver=3.2.0
# -----------------------------------------
echo
echo rfriends for RaspberryPi bullseye $ver
echo
# -----------------------------------------
dir=$(cd $(dirname $0);pwd)
user=`whoami`

sudo apt update
# -----------------------------------------
# 不要デーモンのoff
#
sudo apt -y install sysv-rc-conf

sudo sysv-rc-conf dbus off
sudo sysv-rc-conf triggerhappy off
sudo sysv-rc-conf alsa-utils off
sudo sysv-rc-conf lightdm off
sudo sysv-rc-conf motd off
sudo sysv-rc-conf plymouth off
# -----------------------------------------
# ディレクトリを作成
#
sudo mkdir -p /var/tmp
sudo mkdir -p /var/log/ConsoleKit
sudo mkdir -p /var/log/fsck
sudo mkdir -p /var/log/apt
sudo mkdir -p /var/log/ntpstats
# -----------------------------------------
# Lastlog, wtmp ,btmp の空ファイルを作成
#
sudo touch /var/log/lastlog
sudo touch /var/log/wtmp
sudo touch /var/log/btmp
sudo chmod 664 /var/log/lastlog
sudo chmod 664 /var/log/wtmp
sudo chmod 600 /var/log/btmp
sudo chown root.utmp /var/log/lastlog
sudo chown root.utmp /var/log/wtmp
sudo chown root.utmp /var/log/btmp
# -----------------------------------------
# ログ出力を減らす
#
sudo mv /etc/rsyslog.conf /etc/rsyslog.conf.org
sudo cp -p rsyslog.conf /etc/rsyslog.conf
sudo chown root:root /etc/rsyslog.conf

sudo sed -i -e 's/^daemon.*/#daemon.*/' /etc/rsyslog.conf
sudo sed -i -e 's/^lpr.*/#lpr.*/' /etc/rsyslog.conf
sudo sed -i -e 's/^mail.*/#mail.*/' /etc/rsyslog.conf
sudo sed -i -e 's/^user.*/#user.*/' /etc/rsyslog.conf

sudo sed -i -e 's/^mail.info/#mail.info/' /etc/rsyslog.conf
sudo sed -i -e 's/^mail.warn/#mail.warn/' /etc/rsyslog.conf
sudo sed -i -e 's/^mail.err/#mail.err/' /etc/rsyslog.conf

sudo sed -i -e 's/^news.crit/#news.crit/' /etc/rsyslog.conf
sudo sed -i -e 's/^news.err/#news.err/' /etc/rsyslog.conf
sudo sed -i -e 's/^news.notice/#news.notice/' /etc/rsyslog.conf
# -----------------------------------------
# ログローテート
#
sudo sed -i -e 's/rotate 4/rotate 1/' /etc/logrotate.conf
#
cd /etc/logrotate.d
sudo sed -i -e 's/rotate 12/rotate 1/' alternatives
sudo sed -i -e 's/rotate 12/rotate 1/' apt
#sudo sed -i -e 's/rotate 1/rotate 1/' btmp
#sudo sed -i -e 's/rotate 1/rotate 1/' wtmp
sudo sed -i -e 's/rotate 12/rotate 1/' dpkg
sudo sed -i -e 's/rotate 7/rotate 1/'  rsyslog
sudo sed -i -e 's/rotate 4/rotate 1/'  rsyslog
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
# rc.localを設定する
#
sudo mv -n /etc/rc.local /etc/rc.local.org
sudo cp -p $dir/rc.local /etc/rc.local
sudo chmod +x /etc/rc.local
sudo chown root:root /etc/rc.local
# -----------------------------------------
# .vimrcを設定する
#
cd  ~/
sudo mv -n .vimrc .vimrc.org
sudo cp -p $dir/vimrc .vimrc
sudo chmod 644 .vimrc
# -----------------------------------------
# テンポラリ領域をtmpfs（Ramdisk上）に設定する
#
mkdir -p /home/$user/tmp
mkdir -p /home/$user/smbdir/usr2
#
grep rfriends /etc/fstab
if [ $? = 1 ]; then
cat <<EOF | sudo tee -a /etc/fstab > /dev/null
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

EOF
else echo "already exist"
fi
# -----------------------------------------
# rfriends3のインストール
# -----------------------------------------
cd  ~/
sudo apt install git
git clone https://github.com/rfriends/rfriends_ubuntu.git
cd rfriends_ubuntu
sh rfriends3_ubuntu.sh
# -----------------------------------------
cat <<EOF | sudo tee ~/rfriends3/config/usrdir.ini > /dev/null
#
# 書換不可
#
usrdir = "/home/$user/smbdir/usr2/"
tmpdir = "/home/$user/tmp/"
EOF
# -----------------------------------------
# アプリのインストール
# -----------------------------------------
sudo apt -y install exim4
sudo apt -y install samba
#sudo apt -y install vsftpd
sudo apt install -y lighttpd php-cgi
# -----------------------------------------
# samba setup
#
# log
sudo mkdir -p /var/log/samba
sudo chown root.adm /var/log/samba

sudo mv /etc/samba/smb.conf /etc/samba/smb.conf.org
sudo cp -p smb.conf /etc/samba/smb.conf
sudo chown root:root /etc/samba/smb.conf

sudo systemctl restart smbd nmbd
# -----------------------------------------
# setup lighttpd
#
sudo mv -n /etc/lighttpd/conf-available/15-fastcgi-php.conf /etc/lighttpd/conf-available/15-fastcgi-php.conf.org
sudo cp -p 15-fastcgi-php.conf /etc/lighttpd/conf-available/.
sudo chown root:root /etc/lighttpd/conf-available/15-fastcgi-php.conf

sudo mv -n /etc/lighttpd/lighttpd.conf /etc/lighttpd/lighttpd.conf.org
sudo cp -p $dir/lighttpd.conf /etc/lighttpd/.
sudo chown root:root /etc/lighttpd/lighttpd.conf

sudo cp -p $dir/rfriends3_boot.txt /home/$user/rfriends3/.

mkdir -p /home/$user/lighttpd/uploads/
sudo lighttpd-enable-mod fastcgi
sudo lighttpd-enable-mod fastcgi-php

sudo systemctl enable lighttpd
# -----------------------------------------
cd /etc/logrotate.d
sudo sed -i -e 's/rotate 7/rotate 1/g' samba
sudo sed -i -e 's/rotate 10/rotate 1/' exim4-base
sudo sed -i -e 's/rotate 10/rotate 1/' exim4-paniclog
# -----------------------------------------
# 作成日
# -----------------------------------------
sudo touch /boot/rf3info
exit 0
# -----------------------------------------
