#!/bin/sh

read QUERY_STRING
CONF_FILE="etc/system.conf"

if [ -d "/usr/yi-hack-v4" ]; then
        YI_HACK_PREFIX="/usr/yi-hack-v4"
elif [ -d "/home/yi-hack-v4" ]; then
        YI_HACK_PREFIX="/home/yi-hack-v4"
fi

echo $QUERY_STRING | tr '&' '\n' > $YI_HACK_PREFIX/$CONF_FILE

printf "Content-type: application/json\r\n\r\n"

# Yeah, it's pretty ugly.. but hey, it works.

printf "{\n"
printf "\"%s\":\"%s\"\\n" "error" "false"
printf "}"