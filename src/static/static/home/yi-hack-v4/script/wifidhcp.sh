killall udhcpc
/sbin/udhcpc -i wlan0 -b -s /home/app/script/default.script -x hostname:`hostname`
