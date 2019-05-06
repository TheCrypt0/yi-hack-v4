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
CONF_FILE="$YI_HACK_PREFIX/etc/viewd.conf"

printf "Content-type: application/json\r\n\r\n"

printf "{\n"

if [ $ACTION_TYPE == "getconf" ] ; then

    while IFS= read -r LINE ; do
        if [ ! -z $LINE ] ; then
            if [ "$LINE" == "${LINE#\#}" ] ; then # skip comments
                printf "\"%s\",\n" $(echo "$LINE" | sed -r 's/=/":"/g') # Format to json and replace = with ":"
            fi
        fi
    done < "$CONF_FILE"

    printf "\"%s\":\"%s\",\n"  "VIEWD_FILE"     $(ls $YI_HACK_PREFIX/bin/viewd)
    printf "\"%s\":\"%s\",\n"  "RTSP_FILE"      $(ls $YI_HACK_PREFIX/bin/rtspv4)
    printf "\"%s\":\"%s\",\n"  "LIC_FILE"       $(ls $YI_HACK_PREFIX/etc/viewd_*.lic)
    printf "\"%s\":\"%s\",\n"  "CAMHASH"        $(camhash)
    printf "\"%s\":\"%s\",\n"  "REMOTE_ADDR"    $HTTP_HOST

fi

# Empty values to "close" the json
printf "\"%s\":\"%s\"\n"  "NULL" "NULL"

printf "}"
