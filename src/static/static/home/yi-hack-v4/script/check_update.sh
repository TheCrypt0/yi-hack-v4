#!/bin/sh

REMOTE_VERSION_URL=https://raw.githubusercontent.com/TheCrypt0/yi-hack-v4/master/VERSION
REMOTE_VERSION_FILE=/tmp/hack_new_version

while [ 1 ]; do

    # Get the latest version number from github
    wget -T 5 -O $REMOTE_VERSION_FILE $REMOTE_VERSION_URL &> /dev/null

    if [ -f $REMOTE_VERSION_FILE ]; then
        # The remote version number has been downloaded at boot
        # Check version every 30 minutes
        sleep 1800
    else
        # The remote version number hasn't been downloaded yet (timeout)
        # The camera might be connecting to the wifi
        # Keep checking
        sleep 1
    fi
    
done
