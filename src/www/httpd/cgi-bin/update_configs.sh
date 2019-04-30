#!/bin/sh

printf "Content-type: application/json\r\n\r\n"

read QUERY_STRING

CONF_FILE="etc/system.conf"

if [ -d "/usr/yi-hack-v4" ]; then
        YI_HACK_PREFIX="/usr/yi-hack-v4"
elif [ -d "/home/yi-hack-v4" ]; then
        YI_HACK_PREFIX="/home/yi-hack-v4"
fi

PARAMS=$(echo "$QUERY_STRING" | tr "&" " ")

for S in $PARAMS ; do
    PARAM=$(echo "$S" | tr "=" " ")
    KEY=""
    VALUE=""
    
    for SP in $PARAM ; do
        if [ -z $KEY ]; then
            KEY=$SP
        else
            VALUE=$SP
        fi
    done
    
    if [ $KEY == "hostname" ] ; then
        if [ -z $VALUE ] ; then
            echo "$VALUE" > /etc/hostname
        fi
    else
        sed -i "s/^\(${KEY}\s*=\s*\).*$/\1${VALUE}/" $YI_HACK_PREFIX/$CONF_FILE
    fi   
done

# Yeah, it's pretty ugly.

printf "{\n"
printf "\"%s\":\"%s\"\\n" "error" "false"
printf "}"
