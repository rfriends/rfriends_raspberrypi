#!/bin/sh
# =========================================
# Lighter weight
# =========================================
# 1.00 2024/12/22
ver=3.2.0
# =========================================
os=`cat /etc/os-release | grep VERSION_CODENAME= | sed s/VERSION_CODENAME=//`
if [ $os = 'bookworm' ]; then
 boot=/boot/firmware
else
 boot=/boot
fi
# =========================================
echo
echo Lighter weight rfriends $ver for RaspberryPi $os
echo
# =========================================
dir=$(cd $(dirname $0);pwd)
user=`whoami`
#
sudo raspi-config nonint do_boot_wait 0
sudo raspi-config nonint do_memory_split 16
# =========================================
# システムの軽量化
# =========================================
# -----------------------------------------
# ログ出力を減らす
# -----------------------------------------
sudo cp -n /etc/rsyslog.conf /etc/rsyslog.conf.org

sudo sed -i "/^mail.info/s/^/#/" /etc/rsyslog.conf
sudo sed -i "/^mail.warn/s/^/#/" /etc/rsyslog.conf
sudo sed -i "/^mail.err/s/^/#/"  /etc/rsyslog.conf
sudo sed -i "/^mail./s/^/#/"   /etc/rsyslog.conf

sudo sed -i "/^daemon./s/^/#/" /etc/rsyslog.conf
sudo sed -i "/^lpr./s/^/#/"    /etc/rsyslog.conf
sudo sed -i "/^user./s/^/#/"   /etc/rsyslog.conf
# -----------------------------------------
# ログローテートを減らす
# -----------------------------------------
sudo sed -i -e 's/rotate 4/rotate 1/' /etc/logrotate.conf
#
cd /etc/logrotate.d
sudo sed -i -e 's/rotate 12/rotate 1/' alternatives
sudo sed -i -e 's/rotate 12/rotate 1/' apt
#sudo sed -i -e 's/rotate 1/rotate 1/' btmp
sudo sed -i -e 's/rotate 12/rotate 1/' dpkg
sudo sed -i -e 's/rotate 4/rotate 1/'  ppp
sudo sed -i -e 's/rotate 4/rotate 1/'  rsyslog
#sudo sed -i -e 's/rotate 1/rotate 1/' wtmp

sudo sed -i -e 's/rotate 7/rotate 1/g' samba
sudo sed -i -e 's/rotate 10/rotate 1/' exim4-base
sudo sed -i -e 's/rotate 10/rotate 1/' exim4-paniclog
# -----------------------------------------
echo finished
# -----------------------------------------
