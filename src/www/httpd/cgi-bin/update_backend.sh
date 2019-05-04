#!/bin/sh

if [ -d "/usr/yi-hack-v4" ]; then
        YI_HACK_PREFIX="/usr/yi-hack-v4"
elif [ -d "/home/yi-hack-v4" ]; then
        YI_HACK_PREFIX="/home/yi-hack-v4"
fi

get_action_type()
{   
    CONF="$(echo $QUERY_STRING | cut -d'=' -f1)"
    VAL="$(echo $QUERY_STRING | cut -d'=' -f2)"
    
    if [ $CONF == "action" ] ; then
        echo $VAL
    fi
}

ACTION_TYPE="$(get_action_type)"

REMOTE_VERSION_FILE=/tmp/.hackremotever
REMOTE_NEWVERSION_FILE=/tmp/.hacknewver

LOCAL_VERSION_FILE=/home/yi-hack-v4/version

printf "Content-type: application/json\r\n\r\n"

printf "{\n"

printf "\"%s\":\"%s\",\n"  "LOCAL_VERSION" "$(cat $LOCAL_VERSION_FILE)"
printf "\"%s\":\"%s\",\n"  "REMOTE_VERSION" "$(cat $REMOTE_VERSION_FILE)"
printf "\"%s\":\"%s\",\n"  "NEEDS_UPDATE" "$(cat $REMOTE_NEWVERSION_FILE)"

# Empty values to "close" the json
printf "\"%s\":\"%s\"\n"  "NULL" "NULL"

printf "}"
