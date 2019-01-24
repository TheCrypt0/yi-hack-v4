#!/bin/sh

printf "Content-type: text/plain\r\n\r\n"

CAM=$(cat /home/base/init.sh | grep if=/home/home_ | sed -e 's/.*home_\(.*\) of=.*/\1/')
CPU=$(grep -e Processor -e Hardware /proc/cpuinfo | awk '{print $3}')
CPUUSAGE=$(grep 'cpu ' /proc/stat | awk '{usage=($2+$4)*100/($2+$4+$5)} END {print usage}')
MEM=$(free | grep 'Mem:' | awk '{print $2" "$3" "$4}')
FIRMWARE=$(cat /home/homever)
YIHACK=$(cat /home/yi-hack-v4/version)
ESSID=$(iwconfig wlan0 | grep -e ESSID | sed -e 's/.*ESSID:"\(.*\)"  Nickname.*/\1/')

echo $CAM
echo $CPU
echo $CPUUSAGE
echo $MEM
echo $FIRMWARE
echo $YIHACK
echo $ESSID

