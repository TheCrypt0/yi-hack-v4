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

MAX_RETRY=10
N_RETRY=0

REMOTE_VERSION_URL=https://raw.githubusercontent.com/TheCrypt0/yi-hack-v4/master/VERSION
REMOTE_VERSION_FILE=/tmp/hacknewver

if [[ $(get_config CHECK_UPDATES) == "yes" ]] ; then
    while [ ! -f $REMOTE_VERSION_FILE ] && [ $N_RETRY -le $MAX_RETRY ] ; do
        # Get the latest version number from github
        wget -T 10 -O $REMOTE_VERSION_FILE $REMOTE_VERSION_URL &> /dev/null

        if [ ! -f $REMOTE_VERSION_FILE ]; then
            # The remote version number hasn't been downloaded yet (timeout)
            # The camera might be connecting to the wifi
            # Keep checking every 5 seconds and increment retry number
            sleep 5
            ((N_RETRY++))
        fi    
    done
fi
