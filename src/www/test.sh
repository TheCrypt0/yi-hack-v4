#!/bin/sh

if [ "$#" != 3 ]
then
  echo "usage: test.sh <ip> <username> <password>"
else
  cd _install
  tar cf data.tar bin www
fi

ftp -n $1 << END_SCRIPT
user $2 $3
put data.tar /home/yi-hack-v4/data.tar
bye
END_SCRIPT

rm data.tar

(
echo "open $1"
sleep 1
echo $2
sleep 1
echo $3
sleep 1
echo "cd /home/yi-hack-v4"
echo "tar xf data.tar"
sleep 1
echo "rm data.tar"
sleep 1
echo "cd /home/yi-hack-v4/bin"
echo "killall tinyhttp"
sleep 1
echo "./tinyhttp 80 &"
sleep 1
echo "exit"
) | telnet
