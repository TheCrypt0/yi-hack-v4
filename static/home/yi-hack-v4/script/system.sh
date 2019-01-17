#!/bin/sh

CONF_FILE="etc/system.conf"

if [ -d "/usr/yi-hack-v4" ]; then
        YI_HACK_PREFIX="/usr/yi-hack-v4"
elif [ -d "/home/yi-hack-v4" ]; then
        YI_HACK_PREFIX="/home/yi-hack-v4"
fi

get_config()
{
    key=$1
    grep $1 $YI_HACK_PREFIX/$CONF_FILE | cut -d "=" -f2
}

if [ -d "/usr/yi-hack-v4" ]; then
	export LD_LIBRARY_PATH=/home/libusr:$LD_LIBRARY_PATH:/usr/yi-hack-v4/lib:/home/hd1/yi-hack-v4/lib
	export PATH=$PATH:/usr/yi-hack-v4/bin:/usr/yi-hack-v4/sbin:/home/hd1/yi-hack-v4/bin:/home/hd1/yi-hack-v4/sbin
elif [ -d "/home/yi-hack-v4" ]; then
	export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/home/lib:/home/yi-hack-v4/lib:/tmp/sd/yi-hack-v4/lib
	export PATH=$PATH:/home/base/tools:/home/yi-hack-v4/bin:/home/yi-hack-v4/sbin:/tmp/sd/yi-hack-v4/bin:/tmp/sd/yi-hack-v4/sbin
fi

hostname -F $YI_HACK_PREFIX/etc/hostname

# NOT READY YET

if [[ $(get_config HTTPD) == "yes" ]] ; then
    tinyhttp 80 &
fi

if [[ $(get_config TELNETD) == "yes" ]] ; then
    telnetd
fi

if [[ $(get_config FTPD) == "yes" ]] ; then
    pure-ftpd -B
fi

if [[ $(get_config DROPBEAR) == "yes" ]] ; then
    dropbear -R
fi

if [[ $(get_config CHECK_UPDATES) == "yes" ]] ; then
    $YI_HACK_PREFIX/script/check_update.sh &
fi


if [ -f "/tmp/sd/yi-hack-v4/startup.sh" ]; then
    /tmp/sd/yi-hack-v4/startup.sh
elif [ -f "/home/hd1/yi-hack-v4/startup.sh" ]; then
    /home/hd1/yi-hack-v4/startup.sh
fi
