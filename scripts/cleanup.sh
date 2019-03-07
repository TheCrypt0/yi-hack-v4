#!/bin/bash

#
#  This file is part of yi-hack-v4 (https://github.com/TheCrypt0/yi-hack-v4).
#  Copyright (c) 2019 densanki.
#  Copyright (c) 2019 Davide Maggioni.
#
#  This program is free software: you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation, version 3.
#
#  This program is distributed in the hope that it will be useful, but
#  WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
#  General Public License for more details.
#
#  You should have received a copy of the GNU General Public License
#  along with this program. If not, see <http://www.gnu.org/licenses/>.
#

get_script_dir()
{
    echo "$(cd `dirname $0` && pwd)"
}

source "$(get_script_dir)/common.sh"

require_root

echo ""
echo "------------------------------------------------------------------------"
echo " YI-HACK-V4 - CLEANUP"
echo "------------------------------------------------------------------------"
echo ""

BASE_DIR=$(get_script_dir)/../
BASE_DIR=$(normalize_path $BASE_DIR)

SYSROOT_DIR=$BASE_DIR/sysroot
STATIC_DIR=$BASE_DIR/static
BUILD_DIR=$BASE_DIR/build
OUT_DIR=$BASE_DIR/out

echo "Cleaning sysroot..."
cd $SYSROOT_DIR
rm -r yi_*
echo "Cleaning out dir..."
cd $OUT_DIR
rm -r yi_*

echo "Cleaning src/*/_install folders..."
rm -r $BASE_DIR/src/busybox/_install
rm -r $BASE_DIR/src/dropbear/_install
rm -r $BASE_DIR/src/ftpd/_install
rm -r $BASE_DIR/src/proxychains-ng/_install
rm -r $BASE_DIR/src/static/_install
rm -r $BASE_DIR/src/uClibc/_install
rm -r $BASE_DIR/src/www/_install

echo ""
echo "Finished!"
echo ""
