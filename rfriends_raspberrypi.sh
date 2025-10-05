#!/bin/sh -e
# --------------------------------------
#  install
# --------------------------------------
echo 現在メンテナンス中につき使用できません。
exit 0
# --------------------------------------
echo start
#
sh rpi_install.sh 2>&1 | tee rpi_install.log
#
# --------------------------------------
if [ -z $HOME ]; then
  homedir=`sh -c 'cd && pwd'`
else
  homedir=$HOME
fi
#
echo
echo `cat $homedir/rfriends3/_Rfriends3`
echo
echo "`cat /etc/os-release | grep PRETTY_NAME`"
echo
echo IP : `hostname -I`
echo user : `whoami`
echo
echo "`free`"
#
echo finished
exit 0
