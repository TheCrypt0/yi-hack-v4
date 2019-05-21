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
    grep -w $1 $YI_HACK_PREFIX/$CONF_FILE | cut -d "=" -f2
}

if [ -d "/usr/yi-hack-v4" ]; then
	export LD_LIBRARY_PATH=/home/libusr:$LD_LIBRARY_PATH:/usr/yi-hack-v4/lib:/home/hd1/yi-hack-v4/lib
	export PATH=$PATH:/usr/yi-hack-v4/bin:/usr/yi-hack-v4/sbin:/home/hd1/yi-hack-v4/bin:/home/hd1/yi-hack-v4/sbin
elif [ -d "/home/yi-hack-v4" ]; then
	export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/home/lib:/home/yi-hack-v4/lib:/tmp/sd/yi-hack-v4/lib
	export PATH=$PATH:/home/base/tools:/home/yi-hack-v4/bin:/home/yi-hack-v4/sbin:/tmp/sd/yi-hack-v4/bin:/tmp/sd/yi-hack-v4/sbin
fi

ulimit -s 1024
hostname -F /etc/hostname

if [[ $(get_config DISABLE_CLOUD) == "no" ]] ; then
    (
        cd /home/app
        sleep 2
        ./mp4record &
        ./cloud &
        ./p2p_tnp &
        if [[ $(cat /home/app/.camver) != "yi_dome" ]] ; then
            ./oss &
        fi
        ./watch_process &
    )
elif [[ $(get_config REC_WITHOUT_CLOUD) == "yes" ]] ; then
    (
        cd /home/app
        sleep 2
        ./mp4record &
    )
fi

if [[ $(get_config HTTPD) == "yes" ]] ; then
    httpd -p 80 -h $YI_HACK_PREFIX/www/
fi

if [[ $(get_config TELNETD) == "yes" ]] ; then
    telnetd
fi

if [[ $(get_config FTPD) == "yes" ]] ; then
    if [[ $(get_config BUSYBOX_FTPD) == "yes" ]] ; then
        tcpsvd -vE 0.0.0.0 21 ftpd -w &
    else
        pure-ftpd -B
    fi
fi

if [[ $(get_config SSHD) == "yes" ]] ; then
    dropbear -R
fi

if [[ $(get_config NTPD) == "yes" ]] ; then
    # Wait until all the other processes have been initialized
    sleep 5 && ntpd -p $(get_config NTP_SERVER) &
fi

if [[ $(get_config MQTT) == "yes" ]] ; then
    mqttv4 &
fi

if [[ $(get_config RTSP) == "yes" ]] ; then
    if [[ -f "$YI_HACK_PREFIX/bin/viewd" && -f "$YI_HACK_PREFIX/bin/rtspv4" ]] ; then
        viewd -D -S
        rtspv4 -D -S
    fi
fi

sleep 25 && camhash > /tmp/camhash &

# First run on startup, then every day via crond
$YI_HACK_PREFIX/script/check_update.sh

crond -c $YI_HACK_PREFIX/etc/crontabs

if [ -f "/tmp/sd/yi-hack-v4/startup.sh" ]; then
    /tmp/sd/yi-hack-v4/startup.sh
elif [ -f "/home/hd1/yi-hack-v4/startup.sh" ]; then
    /home/hd1/yi-hack-v4/startup.sh
fi
