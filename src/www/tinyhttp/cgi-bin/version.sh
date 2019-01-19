#!/bin/sh

localver="$(cat ./version)"
remotever="$(wget --no-check-certificate -q -O - https://raw.githubusercontent.com/gaggi/yi-hack-v4/master/VERSION)"

echo "{"
echo "	\"local\": \"$localver\","
echo "	\"remote\": \"$remotever\""
echo "}"
