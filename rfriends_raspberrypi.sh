#!/bin/sh -e
#
# ログありで実行したい場合は、このshを使用して下さい。
#
sh rfriends3_raspberrypi.sh 2>&1 | tee rpi.log
#
echo
echo `cat ../rfriends3/_Rfriends3`
echo
echo "`cat /etc/os-release | grep PRETTY_NAME`"
echo
echo IP : `hostname -I`
echo user : `whoami`
echo
echo "`free`"
#
exit 0
