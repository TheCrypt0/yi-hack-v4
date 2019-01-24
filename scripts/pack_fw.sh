#!/bin/bash

###############################################################################
#  pack_fw.sh
###############################################################################
#  this file is part of yi-hack-v4
#  https://github.com/TheCrypt0/yi-hack-v4
###############################################################################

get_script_dir()
{
    echo "$(cd `dirname $0` && pwd)"
}

create_tmp_dir()
{
    local TMP_DIR=$(mktemp -d)
    
    if [[ ! "$TMP_DIR" || ! -d "$TMP_DIR" ]]; then
        echo "ERROR: Could not create temp dir \"$TMP_DIR\". Exiting."
        exit 1
    fi
    
    echo $TMP_DIR
}

compress_file()
{
    local DIR=$1
    local FILENAME=$2
    local FILE=$DIR/$FILENAME
    if [[ -f "$FILE" ]]; then
        printf "Compressing %s... " $FILENAME
        7za a "$FILE.7z" "$FILE" > /dev/null
        rm -f "$FILE"
        printf "done!\n"
    fi
}

pack_image()
{
    local TYPE=$1
    local CAMERA_ID=$2
    local DIR=$3
    local OUT=$4
    
    printf "> PACKING : %s_%s\n\n" $TYPE $CAMERA_ID
    
    printf "Creating jffs2 filesystem... "
    mkfs.jffs2 -l -e 64 -r $DIR/$TYPE -o $DIR/${TYPE}_${CAMERA_ID}.jffs2 || exit 1
    printf "done!\n"
    printf "Adding U-Boot header... "
    mkimage -A arm -T filesystem -C none -n 0001-hi3518-$TYPE -d $DIR/${TYPE}_${CAMERA_ID}.jffs2 $OUT/${TYPE}_${CAMERA_ID} > /dev/null || exit 1
    printf "done!\n\n"
}

###############################################################################

source "$(get_script_dir)/common.sh"

require_root


if [ $# -ne 1 ]; then
    echo "Usage: pack_sw.sh camera_name"
    echo ""
    exit 1
fi

CAMERA_NAME=$1

check_camera_name $CAMERA_NAME

CAMERA_ID=$(get_camera_id $CAMERA_NAME)

BASE_DIR=$(get_script_dir)/../
BASE_DIR=$(normalize_path $BASE_DIR)

SYSROOT_DIR=$BASE_DIR/sysroot/$CAMERA_NAME
STATIC_DIR=$BASE_DIR/static
BUILD_DIR=$BASE_DIR/build
OUT_DIR=$BASE_DIR/out/$CAMERA_NAME

echo ""
echo "------------------------------------------------------------------------"
echo " YI-HACK-V4 - FIRMWARE PACKER"
echo "------------------------------------------------------------------------"
printf " camera_name      : %s\n" $CAMERA_NAME
printf " camera_id        : %s\n" $CAMERA_ID
printf "                      \n"
printf " sysroot_dir      : %s\n" $SYSROOT_DIR
printf " static_dir       : %s\n" $STATIC_DIR
printf " build_dir        : %s\n" $BUILD_DIR
printf " out_dir          : %s\n" $OUT_DIR
echo "------------------------------------------------------------------------"
echo ""

printf "Starting...\n\n"

sleep 1 

printf "Checking if the required sysroot exists... "

# Check if the sysroot exist
if [[ ! -d "$SYSROOT_DIR/home" || ! -d "$SYSROOT_DIR/rootfs" ]]; then
    printf "\n\n"
    echo "ERROR: Cannot find the sysroot. Missing:"
    echo " > $SYSROOT_DIR/home"
    echo " > $SYSROOT_DIR/rootfs"
    echo ""
    echo "You should create the $CAMERA_NAME sysroot before trying to pack the firmware."
    exit 1
else
    printf "yeah!\n"
fi

printf "Creating the out directory... "
mkdir -p $OUT_DIR
printf "%s created!\n\n" $OUT_DIR

printf "Creating the tmp directory... "
TMP_DIR=$(create_tmp_dir)
printf "%s created!\n\n" $TMP_DIR

# Copy the sysroot to the tmp dir
printf "Copying the sysroot contents... "
rsync -a $SYSROOT_DIR/rootfs/* $TMP_DIR/rootfs || exit 1
rsync -a $SYSROOT_DIR/home/* $TMP_DIR/home || exit 1
printf "done!\n"

# Copy the static files to the tmp dir
printf "Copying the static files... "
rsync -a $STATIC_DIR/rootfs/* $TMP_DIR/rootfs || exit 1
rsync -a $STATIC_DIR/home/* $TMP_DIR/home || exit 1
printf "done!\n"

# Copy the build files to the tmp dir
printf "Copying the build files... "
rsync -a $BUILD_DIR/rootfs/* $TMP_DIR/rootfs || exit 1
rsync -a $BUILD_DIR/home/* $TMP_DIR/home || exit 1
printf "done!\n"

# insert the version file
printf "Copying the version file... "
cp $BASE_DIR/VERSION $TMP_DIR/home/yi-hack-v4/version
printf "done!\n\n"

# fix the files ownership
printf "Fixing the files ownership... "
chown -R root:root $TMP_DIR/*
printf "done!\n\n"

# Compress a couple of the yi app files
compress_file "$TMP_DIR/home/app" cloudAPI
compress_file "$TMP_DIR/home/app" oss
compress_file "$TMP_DIR/home/app" p2p_tnp
compress_file "$TMP_DIR/home/app" rmm

# Compress the yi-hack-v4 folder
printf "Compressing yi-hack-v4... "
7za a $TMP_DIR/home/yi-hack-v4/yi-hack-v4.7z $TMP_DIR/home/yi-hack-v4/* > /dev/null

# Delete all the compressed files except system_init.sh and yi-hack-v4.7z
find $TMP_DIR/home/yi-hack-v4/script/ -maxdepth 0 ! -name 'system_init.sh' -type f -exec rm -f {} +
find $TMP_DIR/home/yi-hack-v4/* -maxdepth 0 -type d ! -name 'script' -exec rm -rf {} +
find $TMP_DIR/home/yi-hack-v4/* -maxdepth 0 -type f -not -name 'yi-hack-v4.7z' -exec rm {} +
printf "done!\n\n"

# home 
pack_image "home" $CAMERA_ID $TMP_DIR $OUT_DIR

# rootfs
pack_image "rootfs" $CAMERA_ID $TMP_DIR $OUT_DIR

# Cleanup
printf "Cleaning up the tmp folder... "
rm -rf $TMP_DIR
printf "done!\n\n"

echo "------------------------------------------------------------------------"
echo " Finished!"
echo "------------------------------------------------------------------------"

