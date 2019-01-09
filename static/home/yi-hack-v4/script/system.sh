#!/bin/sh

CONF_FILE="/yi-hack-v4/etc/system.conf"

if [ -d "/usr/yi-hack-v4" ]; then
        YI_HACK_V4_PREFIX="/usr"
elif [ -d "/home/yi-hack-v4" ]; then
        YI_HACK_V4_PREFIX="/home"
fi

get_config()
{
        key=$1
        grep $1 $YI_HACK_V4_PREFIX$CONF_FILE | cut -d "=" -f2
}

if [ -d "/usr/yi-hack-v4" ]; then
	export LD_LIBRARY_PATH=/home/libusr:$LD_LIBRARY_PATH:/usr/yi-hack-v4/lib:/home/hd1/yi-hack-v4/lib
	export PATH=$PATH:/usr/yi-hack-v4/bin:/usr/yi-hack-v4/sbin:/home/hd1/yi-hack-v4/bin:/home/hd1/yi-hack-v4/sbin
elif [ -d "/home/yi-hack-v4" ]; then
	export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/home/lib:/home/yi-hack-v4/lib:/tmp/sd/yi-hack-v4/lib
	export PATH=$PATH:/home/base/tools:/home/yi-hack-v4/bin:/home/yi-hack-v4/sbin:/tmp/sd/yi-hack-v4/bin:/tmp/sd/yi-hack-v4/sbin
fi

hostname -F $YI_HACK_V4_PREFIX/yi-hack-v4/etc/hostname

if [[ $(get_config HTTPD) == "yes" ]] ; then
	lwsws -D
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

# Get the latest version number from github
wget -T 5 -O /tmp/yihack_new_version https://raw.githubusercontent.com/TheCrypt0/yi-hack-v4/master/VERSION 


if [ -f "/tmp/sd/yi-hack-v4/startup.sh" ]; then
	/tmp/sd/yi-hack-v4/startup.sh
elif [ -f "/home/hd1/yi-hack-v4/startup.sh" ]; then
	/home/hd1/yi-hack-v4/startup.sh
fi
