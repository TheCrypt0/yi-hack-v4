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

# Yeah, it's pretty ugly.. but hey, it works.

printf "{\n"
printf "\"%s\":\"%s\",\n" "HTTPD"           "$(get_config HTTPD)"
printf "\"%s\":\"%s\",\n" "TELNETD"         "$(get_config TELNETD)"
printf "\"%s\":\"%s\",\n" "SSHD"            "$(get_config SSHD)"
printf "\"%s\":\"%s\",\n" "FTPD"            "$(get_config FTPD)"
printf "\"%s\":\"%s\",\n" "PROXYCHAINSNG"   "$(get_config PROXYCHAINSNG)"
printf "\"%s\":\"%s\",\n" "CHECK_UPDATES"   "$(get_config CHECK_UPDATES)"
printf "\"%s\":\"%s\",\n" "DISABLE_CLOUD"   "$(get_config DISABLE_CLOUD)"
printf "\"%s\":\"%s\"\n"  "NTPD"            "$(get_config NTPD)"

printf "}"
