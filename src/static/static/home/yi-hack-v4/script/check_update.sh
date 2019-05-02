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
REMOTE_VERSION_FILE=/tmp/.hackremotever
REMOTE_NEWVERSION_FILE=/tmp/.hacknewver

LOCAL_VERSION_FILE=/home/yi-hack-v4/version

if [[ $(get_config CHECK_UPDATES) == "yes" ]] ; then
    while : ; do
        # Get the latest version number from github
        wget -T 10 -O $REMOTE_VERSION_FILE $REMOTE_VERSION_URL &> /dev/null

        if [ ! -f $REMOTE_VERSION_FILE ]; then
            # The remote version number hasn't been downloaded yet (timeout)
            # The camera might be connecting to the wifi
            # Keep checking every 5 seconds and increment retry number
            sleep 5
            ((N_RETRY++))
        fi
        
        [ ! -f $REMOTE_VERSION_FILE ] && [ $N_RETRY -le $MAX_RETRY ] || break
    done
    
    if [ -f $REMOTE_VERSION_FILE ] ; then
        V_LOCAL=$(cat $LOCAL_VERSION_FILE | cut -d'_' -f1)
        V_REMOTE=$(cat $REMOTE_VERSION_FILE | cut -d'_' -f1)
        
        LOCAL_MAJOR=$(echo $V_LOCAL | cut -d'.' -f1)
        LOCAL_MINOR=$(echo $V_LOCAL | cut -d'.' -f2)
        LOCAL_PATCH=$(echo $V_LOCAL | cut -d'.' -f3)

        REMOTE_MAJOR=$(echo $V_REMOTE | cut -d'.' -f1)
        REMOTE_MINOR=$(echo $V_REMOTE | cut -d'.' -f2)
        REMOTE_PATCH=$(echo $V_REMOTE | cut -d'.' -f3)
        
        V_LOCAL_NUM=$(printf "%03d%03d%03d" $LOCAL_MAJOR $LOCAL_MINOR $LOCAL_PATCH)
        V_REMOTE_NUM=$(printf "%03d%03d%03d" $REMOTE_MAJOR $REMOTE_MINOR $REMOTE_PATCH)
        
        if [ $V_LOCAL_NUM -lt $V_REMOTE_NUM ] ; then
            echo "yes" > $REMOTE_NEWVERSION_FILE
        elif [ $V_LOCAL_NUM -eq $V_REMOTE_NUM ] ; then
            echo "no" > $REMOTE_NEWVERSION_FILE
        elif [ $V_LOCAL_NUM -gt $V_REMOTE_NUM ] ; then
            echo "no_currentversionisbeta" > $REMOTE_NEWVERSION_FILE
        fi
    fi
fi
