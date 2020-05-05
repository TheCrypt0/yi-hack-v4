#!/bin/sh

NUM=-1

CONF="$(echo $QUERY_STRING | cut -d'=' -f1)"
VAL="$(echo $QUERY_STRING | cut -d'=' -f2)"

if [ "$CONF" == "num" ] ; then
    NUM=$VAL
fi

if [ $NUM -ne -1 ] ; then
    ipc_cmd -p $NUM
fi

printf "Content-type: application/json\r\n\r\n"

printf "{\n"
printf "}"
