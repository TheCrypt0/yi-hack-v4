#!/bin/sh

if [ -d "/usr/yi-hack-v4" ]; then
    YI_HACK_V4_PREFIX="/usr"
    YI_PREFIX="/home"
    UDHCPC_SCRIPT_DEST="/home/default.script"
elif [ -d "/home/yi-hack-v4" ]; then
    YI_HACK_V4_PREFIX="/home"
    YI_PREFIX="/home/app"
    UDHCPC_SCRIPT_DEST="/home/app/script/default.script"
fi

ARCHIVE_FILE="$YI_HACK_V4_PREFIX/yi-hack-v4/yi-hack-v4.7z"
DESTDIR="$YI_HACK_V4_PREFIX/yi-hack-v4"

DHCP_SCRIPT_DEST="/home/app/script/wifidhcp.sh"
UDHCP_SCRIPT="$YI_HACK_V4_PREFIX/yi-hack-v4/script/default.script"
DHCP_SCRIPT="$YI_HACK_V4_PREFIX/yi-hack-v4/script/wifidhcp.sh"

files=`find $YI_PREFIX -maxdepth 1 -name "*.7z"`
if [ ${#files[@]} -gt 0 ]; then
	/home/base/tools/7za x "$YI_PREFIX/*.7z" -y -o$YI_PREFIX
	rm $YI_PREFIX/*.7z
fi

if [ -f $ARCHIVE_FILE ]; then
	/home/base/tools/7za x $ARCHIVE_FILE -y -o$DESTDIR
	rm $ARCHIVE_FILE
fi


mkdir -p $YI_HACK_V4_PREFIX/yi-hack-v4/etc/crontabs
mkdir -p $YI_HACK_V4_PREFIX/yi-hack-v4/etc/dropbear
