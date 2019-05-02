#!/bin/bash

#
#  This file is part of yi-hack-v4 (https://github.com/TheCrypt0/yi-hack-v4).
#  Copyright (c) 2018-2019 Davide Maggioni.
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
    echo "$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
}

get_sysroot_dir()
{
    local SYSROOT_DIR=$(get_script_dir)/../sysroot
    echo "$(normalize_path $SYSROOT_DIR)"
}

create_sysroot_dir()
{
    local CAMERA_NAME=$1
    local SYSROOT_BASE_DIR=$2

    local SYSROOT_DIR=$SYSROOT_BASE_DIR/$CAMERA_NAME
    if [[ -d $SYSROOT_DIR/home && -d $SYSROOT_DIR/rootfs ]]; then
        echo "ERROR: The $CAMERA_NAME sysroot folder already exists. Exiting."
        echo ""
        exit 1
    fi
    
    echo "Creating the sysroot dirs.."
    mkdir -p "$SYSROOT_DIR/home"
    echo "\"$SYSROOT_DIR/home\" folder created!"
    mkdir -p "$SYSROOT_DIR/rootfs"
    echo "\"$SYSROOT_DIR/rootfs\" folder created!"
}

jffs2_mount()
{
    local JFFS2_FILE=$1
    local JFFS2_MOUNT=$2
    
    # cleanup if necessary
    umount /dev/mtdblock0 &>/dev/null
    modprobe -r mtdram >/dev/null
    modprobe -r mtdblock >/dev/null

    modprobe mtdram total_size=32768 erase_size=64 || exit 1
    modprobe mtdblock || exit 1
    dd if="$JFFS2_FILE" of=/dev/mtdblock0 &>/dev/null || exit 1
    mount -t jffs2 /dev/mtdblock0 "$JFFS2_MOUNT" || exit 1
}

jffs2_umount()
{
    local JFFS2_MOUNT=$1
    umount $JFFS2_MOUNT
    umount /dev/mtdblock0 &>/dev/null
}

jffs2_copy()
{
    local JFFS2_FILE=$1
    local DEST_DIR=$2
    
    local TMP_DIR=$(mktemp -d)
    
    if [[ ! "$TMP_DIR" || ! -d "$TMP_DIR" ]]; then
        echo "ERROR: Could not create temp dir \"$TMP_DIR\". Exiting."
        exit 1
    fi
    
    jffs2_mount $JFFS2_FILE $TMP_DIR
    rsync -a $TMP_DIR/* $DEST_DIR
    jffs2_umount $TMP_DIR
    
    rm -rf "$TMP_DIR"
}

extract_stock_fw()
{
    local CAMERA_ID=$1
    local SYSROOT_DIR=$2
    local FW_DIR=$3
    
    local FIRMWARE_HOME=$FW_DIR/home_$CAMERA_ID
    local FIRMWARE_ROOTFS=$FW_DIR/rootfs_$CAMERA_ID
    
    local FIRMWARE_HOME_DESTDIR=$SYSROOT_DIR/home
    local FIRMWARE_ROOTFS_DESTDIR=$SYSROOT_DIR/rootfs
    
    echo "Extracting the stock firmware images..."
    
    if [[ ! -f "$FIRMWARE_HOME" || ! -f "$FIRMWARE_ROOTFS" ]]; then
        echo "ERROR: $FIRMWARE_HOME or $FIRMWARE_ROOTFS not found. Exiting."
        exit 1
    fi
    
    # copy the stock firmware images contents to the sysroot
    
    printf "Extracting \"home_$CAMERA_ID\" image to \"$FIRMWARE_HOME_DESTDIR\"... "
    dd bs=64 skip=1 if="$FIRMWARE_HOME" of="$FIRMWARE_HOME.jffs2.tmp" &> /dev/null || exit 1
    jffs2_copy $FIRMWARE_HOME.jffs2.tmp $FIRMWARE_HOME_DESTDIR
    rm -rf $FIRMWARE_HOME.jffs2.tmp
    echo "done!"
    
    printf "Extracting \"rootfs_$CAMERA_ID\" image to \"$FIRMWARE_ROOTFS_DESTDIR\"... "
    dd bs=64 skip=1 if="$FIRMWARE_ROOTFS" of="$FIRMWARE_ROOTFS.jffs2.tmp" &> /dev/null || exit 1
    jffs2_copy $FIRMWARE_ROOTFS.jffs2.tmp $FIRMWARE_ROOTFS_DESTDIR
    rm -rf $FIRMWARE_ROOTFS.jffs2.tmp
    echo "done!"
    
}

generate_pem_certificate_from_xiaomi_binary_key()
{
    # This took me way too much time that I'm confident to admit
    # Really.
    
    local RSA_PUB_KEY=$1
    local RSA_CERT=$2
    
    if [ ! -f "$RSA_PUB_KEY" ]; then
        printf "ERROR: Cannot find the rsa public key \"%s\"\n" $RSA_PUB_KEY
        printf "Exiting...\n\n"
        exit 0
    fi
    
    local TMP_DIR=$(mktemp -d)
    
    if [[ ! "$TMP_DIR" || ! -d "$TMP_DIR" ]]; then
        echo "ERROR: Could not create temp dir \"$TMP_DIR\". Exiting."
        exit 1
    fi
    
    dd if=$RSA_PUB_KEY of=$TMP_DIR/modulus.bin bs=1 count=256 
    dd if=$RSA_PUB_KEY of=$TMP_DIR/exponent.bin bs=1 skip=256 count=3
    echo 'MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA' | base64 -d > $TMP_DIR/header.bin
    echo '02 03' | xxd -r -p > $TMP_DIR/mid-header.bin
    cat $TMP_DIR/header.bin $TMP_DIR/modulus.bin $TMP_DIR/mid-header.bin $TMP_DIR/exponent.bin > $TMP_DIR/key.der
    openssl pkey -inform der -outform pem -pubin -in $TMP_DIR/key.der -out $TMP_DIR/key.pem || exit 1
    
    cp $TMP_DIR/key.pem $RSA_CERT
    
    rm -rf "$TMP_DIR"
}

extract_fw_update()
{
    # extract_fw_update 
    # Based on the script: y18m (17CN) unpacker 0.1 by MP77V 4pda.ru 04.05.2017

    local CAMERA_ID=$1
    local SYSROOT_DIR=$2
    local FW_DIR=$3
      
    local UPDATE_FW=""
    local RSA_PUB_KEY=$FW_DIR/../common/pub_key
    local RSA_PEM_CERT=$FW_DIR/../common/pub_key.pem
    
    if [ $CAMERA_ID == "v201" ]; then
        # The yi_dome uses a different filename for the update
        UPDATE_FW=$FW_DIR/home_v200m
    else
        UPDATE_FW=$FW_DIR/home_${CAMERA_ID}m
    fi
    
    if [ ! -f $UPDATE_FW ] ; then
        printf "WARNING: Cannot find \"%s\"\n" $UPDATE_FW
        printf "Skipping fw update...\n\n"
        return 0
    fi
    
    if [ ! -f $RSA_PUB_KEY ] ; then
        printf "ERROR: Cannot find the rsa public key \"%s\"\n" $RSA_PUB_KEY
        printf "Skipping fw update...\n\n"
        return 0
    fi
    
    printf "Update firmware file \"%s\" found! Extracting...\n" home_${CAMERA_ID}m

    chunk()
    {
        if [ -z "${3}" ]; then
            tail -c +${2} ${1}
        else
            head -c $(($2 + $3)) ${1} | tail -c ${3}
        fi
    }
    
    printf "Generating .pem cerificate from Xiaomi rsa key...\n"
    generate_pem_certificate_from_xiaomi_binary_key $RSA_PUB_KEY $RSA_PEM_CERT
    printf "RSA PEM CERTIFICATE GENERATED!\n"

    hdr="$(chunk ${UPDATE_FW} 0 22)"
    echo -e "\n   hdr=\"${hdr}\""

    hdr="$FW_DIR/hdr.dec"
    echo -n "" >${hdr}
    
    for ((i = 0; i <= 4; i++)); do
        chunk ${UPDATE_FW} $((22 + 256 * $i)) 256 | openssl rsautl -inkey $RSA_PEM_CERT -pubin -raw | base64 -d >>${hdr}
    done
    
    rm $RSA_PEM_CERT
    
    local md5="$(chunk ${hdr}  0 33)"
    local key="$(chunk ${hdr} 33 33)"
    local ver="$(chunk ${hdr} 66 22)"

    echo -e "   ver=\"$ver\"\n   key=\"$key\"\n   md5=\"$md5\""

    chunk ${hdr} $((33 + 33 +22 + 1)) > "$FW_DIR/update.7z.tmp"
    chunk ${UPDATE_FW}  $((22 + 1280 + 1))  >> "$FW_DIR/update.7z.tmp"
    rm -f ${hdr}

    sum="$(md5sum $FW_DIR/update.7z.tmp | cut -f1 -d' ')"
    echo -e "md5sum=\"${sum}\"\n"

    rm -rf ${wd} &>/dev/null

    if [ "$md5" != "$sum" ]; then
        echo "!!! Incorrect checksumm !!!"
        exit 4
    fi
    
    mkdir $FW_DIR/tmp

    7za x -y -o$FW_DIR/tmp -p$key $FW_DIR/update.7z.tmp | tail -n 6
    test "$?" -eq 0 && echo "END" || exit 5
    
    # Sometimes some files in the update are 7zipped 
    # Let's unpack them
    find $FW_DIR/tmp -type f -name "*.7z" -execdir 7za x {} \; -exec rm -- {} \; > /dev/null || exit 0
    
    # Copy all the extracted files to the sysroot dir
    rsync -a $FW_DIR/tmp/* $SYSROOT_DIR/
    
    # Cleanup
    rm -f  "$FW_DIR/update.7z.tmp"
    rm -rf "$FW_DIR/tmp/"
    
    printf "Update applied to the sysroot!\n"
}

###############################################################################

source "$(get_script_dir)/common.sh"

require_root

if [ $# -ne 1 ]; then
    echo "Usage: init_sysroot.sh camera_name"
    echo ""
    exit 1
fi

CAMERA_NAME=$1

check_camera_name $CAMERA_NAME

CAMERA_ID=$(get_camera_id $CAMERA_NAME)
SYSROOT_BASE_DIR=$(get_sysroot_dir)
SYSROOT_DIR=$SYSROOT_BASE_DIR/$CAMERA_NAME
FIRMWARE_DIR=$(normalize_path $(get_script_dir)/../stock_firmware)/$CAMERA_NAME

echo ""
echo "------------------------------------------------------------------------"
echo " YI-HACK-V4 - INIT SYSROOT"
echo "------------------------------------------------------------------------"
printf " camera_name      : %s\n" $CAMERA_NAME
printf " camera_id        : %s\n" $CAMERA_ID
printf "\n"
printf " sysroot_base_dir : %s\n" $SYSROOT_BASE_DIR
printf " sysroot_dir      : %s\n" $SYSROOT_DIR
printf " firmware_dir     : %s\n" $FIRMWARE_DIR
echo "------------------------------------------------------------------------"
echo ""

echo ""

if [[ ! -d "$FIRMWARE_DIR" ]]; then
    printf "ERROR: Cannot find %s\nExiting." $FIRMWARE_DIR
    exit 1
fi

# Create the needed directories
create_sysroot_dir $CAMERA_NAME $SYSROOT_BASE_DIR

echo ""

# Extract the stock fw to the camera's sysroot
extract_stock_fw $CAMERA_ID $SYSROOT_DIR $FIRMWARE_DIR

printf "\n"

# Extract and decrypy the stock firmware update
extract_fw_update $CAMERA_ID $SYSROOT_DIR $FIRMWARE_DIR

echo ""

echo "Success!"
echo ""

exit 0


