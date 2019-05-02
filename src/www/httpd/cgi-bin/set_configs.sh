#!/bin/sh

if [ -d "/usr/yi-hack-v4" ]; then
        YI_HACK_PREFIX="/usr/yi-hack-v4"
elif [ -d "/home/yi-hack-v4" ]; then
        YI_HACK_PREFIX="/home/yi-hack-v4"
fi

get_conf_type()
{   
    CONF="$(echo $QUERY_STRING | cut -d'=' -f1)"
    VAL="$(echo $QUERY_STRING | cut -d'=' -f2)"
    
    if [ $CONF == "conf" ] ; then
        echo $VAL
    fi
}

CONF_TYPE="$(get_conf_type)"
CONF_FILE=""

if [ $CONF_TYPE == "mqtt" ] ; then
    CONF_FILE="$YI_HACK_PREFIX/etc/mqttv4.conf"
else
    CONF_FILE="$YI_HACK_PREFIX/etc/$CONF_TYPE.conf"
fi

read POST_DATA

PARAMS=$(echo "$POST_DATA" | tr "&" " ")

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
    
    if [ $KEY == "HOSTNAME" ] ; then
        if [ ! -z $VALUE ] ; then
            echo "$VALUE" > /etc/hostname
        fi
    else
        sed -i "s/^\(${KEY}\s*=\s*\).*$/\1${VALUE}/" $CONF_FILE
    fi   
done

# Yeah, it's pretty ugly.

printf "Content-type: application/json\r\n\r\n"

printf "{\n"
printf "\"%s\":\"%s\"\\n" "error" "false"
printf "}"
