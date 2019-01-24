#!/bin/bash

###############################################################################
#  init_sysroot.all.sh
###############################################################################
#  this file is part of yi-hack-v4
#  https://github.com/TheCrypt0/yi-hack-v4
###############################################################################

get_script_dir()
{
    echo "$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
}

###############################################################################

source "$(get_script_dir)/common.sh"

require_root

SCRIPT_DIR=$(get_script_dir)

for CAMERA_NAME in "${!CAMERAS[@]}"; do 
    $SCRIPT_DIR/init_sysroot.sh $CAMERA_NAME
done
