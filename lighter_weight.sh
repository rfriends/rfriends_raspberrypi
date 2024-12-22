#!/bin/sh
# =========================================
# Lighter weight
# =========================================
# 1.00 2024/12/22
ver=3.2.0
# =========================================
echo
echo Lighter weight rfriends for RaspberryPi bullseye $ver
echo
# =========================================
os=`cat /etc/os-release | grep VERSION_CODENAME= | sed s/VERSION_CODENAME=//`
if [ os=bookwarm ]; then
 boot=/boot/firmware
else
 boot=/boot
fi
dir=$(cd $(dirname $0);pwd)
user=`whoami`
# =========================================
# システムの軽量化
# =========================================
# -----------------------------------------
# CAMERAモジュールの停止
sed -i '/検索文字列/s/^/#/' 
# -----------------------------------------
# -----------------------------------------
# 不要デーモンのoff
# -----------------------------------------
sudo apt-get -y install sysv-rc-conf

sudo sysv-rc-conf dbus off
sudo sysv-rc-conf triggerhappy off
sudo sysv-rc-conf alsa-utils off
sudo sysv-rc-conf lightdm off
sudo sysv-rc-conf motd off
sudo sysv-rc-conf plymouth off
# -----------------------------------------
# ディレクトリを作成
# -----------------------------------------
sudo mkdir -p /var/tmp
sudo mkdir -p /var/log/ConsoleKit
sudo mkdir -p /var/log/fsck
sudo mkdir -p /var/log/apt
sudo mkdir -p /var/log/ntpstats
# -----------------------------------------
# Lastlog, wtmp ,btmp の空ファイルを作成
# -----------------------------------------
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
# -----------------------------------------
sudo cp -n /etc/rsyslog.conf /etc/rsyslog.conf.org

sed -i "s/^daemon.*/#/" /etc/rsyslog.conf
sed -i "s/^lpr.*/#/"    /etc/rsyslog.conf
sed -i "s/^mail.*/#/"   /etc/rsyslog.conf
sed -i "s/^user.*/#/"   /etc/rsyslog.conf

sed -i "s/^mail.info/#/" /etc/rsyslog.conf
sed -i "s/^mail.warn/#/" /etc/rsyslog.conf
sed -i "s/^mail.err/#/"  /etc/rsyslog.conf

#sudo sed -i -e 's/^news.crit/#news.crit/' /etc/rsyslog.conf
#sudo sed -i -e 's/^news.err/#news.err/' /etc/rsyslog.conf
#sudo sed -i -e 's/^news.notice/#news.notice/' /etc/rsyslog.conf
# -----------------------------------------
# ログローテートを減らす
# -----------------------------------------
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

sudo sed -i -e 's/rotate 7/rotate 1/g' samba
sudo sed -i -e 's/rotate 10/rotate 1/' exim4-base
sudo sed -i -e 's/rotate 10/rotate 1/' exim4-paniclog
# -----------------------------------------
echo finished
# -----------------------------------------
