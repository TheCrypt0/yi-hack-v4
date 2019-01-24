#!/bin/sh

printf "Content-type: text/plain\r\n\r\n"

$( printf "%s\n" "$QUERY_STRING" | sed 's/%20/ /g' )
