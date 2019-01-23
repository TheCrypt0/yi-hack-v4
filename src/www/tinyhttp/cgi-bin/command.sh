#!/bin/sh
$( printf "%s\n" "$QUERY_STRING" | sed 's/%20/ /g' )
