#!/bin/sh
# =========================================
# Lighter weight
# =========================================
# 1.00 2024/12/22
ver=3.2.0
# =========================================
os=`cat /etc/os-release | grep VERSION_CODENAME= | sed s/VERSION_CODENAME=//`
if [ $os = 'trixie' ]; then
 boot=/boot/firmware
elif [ $os = 'bookworm' ]; then
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
# =========================================
# システムの軽量化
# =========================================
# -----------------------------------------
# ジャーナル
# -----------------------------------------
#Storage=none
sudo sed  -i "/#Storage=auto/c Storage=none" /etc/systemd/journald.conf
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
#  rc.localの有効化
# -----------------------------------------
cat <<EOF | sudo tee /etc/systemd/system/rc-local.service > /dev/null
[Unit]
 Description=/etc/rc.local Compatibility
 ConditionPathExists=/etc/rc.local

[Service]
 Type=forking
 ExecStart=/etc/rc.local start
 TimeoutSec=0
 StandardOutput=tty
 RemainAfterExit=yes
 SysVStartPriority=99

[Install]
 WantedBy=multi-user.target
EOF

sudo systemctl enable rc-local.service
# -----------------------------------------
echo finished
# -----------------------------------------
