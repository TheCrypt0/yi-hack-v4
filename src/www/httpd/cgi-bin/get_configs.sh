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

printf "Content-type: application/json\r\n\r\n"

printf "{\n"

while IFS= read -r LINE ; do
    if [ ! -z $LINE ] ; then
        printf "\"%s\",\n" $(echo "$LINE" | sed -r 's/=/":"/g') # Format to json and replace = with ":"
    fi
done < "$YI_HACK_PREFIX/$CONF_FILE"

printf "\"%s\":\"%s\",\n"  "HOSTNAME" "$(cat /etc/hostname)"

# Empty values to "close" the json
printf "\"%s\":\"%s\"\n"  "NULL" "NULL"

printf "}"
