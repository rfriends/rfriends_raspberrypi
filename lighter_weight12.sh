#!/bin/sh
# =========================================
# Lighter weight
# =========================================
# 1.00 2024/12/22
ver=3.2.0
# =========================================
os=`cat /etc/os-release | grep VERSION_CODENAME= | sed s/VERSION_CODENAME=//`
if [ $os = 'bookwarm' ]; then
 boot=/boot/firmware
else
 boot=/boot
fi
# =========================================
echo
echo Lighter weight rfriends for RaspberryPi($os) $ver
echo
# =========================================
dir=$(cd $(dirname $0);pwd)
user=`whoami`
# =========================================
# システムの軽量化
# =========================================
# -----------------------------------------
# ジャーナル
# -----------------------------------------
#Storage=none
sudo mv -n /etc/systemd/journald.conf /etc/systemd/journald.conf.org
sudo cp -p $dir/journald.conf /etc/systemd
sudo chmod 644 /etc/systemd/journald.conf
sudo chown root:root /etc/systemd/journald.conf
# -----------------------------------------
# console
# -----------------------------------------
sudo cp -p $dir/console-setup /etc/default/.
sudo chmod 644 /etc/default/console-setup
sudo chown roort:root /etc/default/console-setup
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
#sudo sed -i -e 's/rotate 1/rotate 1/' wtmp

sudo sed -i -e 's/rotate 7/rotate 1/g' samba
sudo sed -i -e 's/rotate 10/rotate 1/' exim4-base
sudo sed -i -e 's/rotate 10/rotate 1/' exim4-paniclog
# -----------------------------------------
echo finished
# -----------------------------------------
