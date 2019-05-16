#!/bin/sh

if [ -d "/usr/yi-hack-v4" ]; then
        YI_HACK_PREFIX="/usr/yi-hack-v4"
elif [ -d "/home/yi-hack-v4" ]; then
        YI_HACK_PREFIX="/home/yi-hack-v4"
fi

get_file_type()
{   
    CONF="$(echo $QUERY_STRING | cut -d'=' -f1)"
    VAL="$(echo $QUERY_STRING | cut -d'=' -f2)"
    
    if [ $CONF == "file" ] ; then
        echo $VAL
    fi
}

get_random_tmp_file()
{
    local CNT=5
    local RND=""
    local TMP_FILE=""
    
    while : ; do
        RND=$(</dev/urandom tr -dc 0-9 | dd bs=$CNT count=1 2>/dev/null | sed -e 's/^0\+//' )
        TMP_FILE="/tmp/.tmpupload.$RND"
        
        [ -f $TMP_FILE ] || break
    done
    
    echo $TMP_FILE
}

get_file_from_post()
{
    local FILE=$1

    local CR=`printf '\r'`

    IFS="$CR"
    read -r delim_line
    IFS=""

    while read -r line; do
        test x"$line" = x"" && break
        test x"$line" = x"$CR" && break
    done

    cat > "$FILE"

    # We need to delete the tail of "\r\ndelim_line--\r\n"
    tail_len=$((${#delim_line} + 6))

    # Get and check file size
    filesize=`ls -l "$FILE" | awk '{print $5}'`

    # Truncate the file
    dd of="$FILE" seek=$((filesize - tail_len)) bs=1 count=0 >/dev/null 2>/dev/null
}

printf "Content-type: application/json\r\n\r\n"

FILE_TYPE="$(get_file_type)"
TMP_FILE=$(get_random_tmp_file)

CUT_FILE_TYPE=$(echo $FILE_TYPE | cut -d'_' -f1)

if [[ "$CUT_FILE_TYPE" == "home" || "$CUT_FILE_TYPE" == "rootfs" ]] ; then
    # If home or rootfs image, place directly on sd card
    get_file_from_post "/tmp/sd/$FILE_TYPE"
else
    get_file_from_post $TMP_FILE

    if [ "$FILE_TYPE" == "rtspv4__upload" ] ; then
        7za x "$TMP_FILE" -y -o. &>/dev/null
        
        killall viewd rtspv4
        
        cp -rf rtspv4__*/* $YI_HACK_PREFIX/
        rm -rf rtspv4__*
        
        chmod +x $YI_HACK_PREFIX/bin/viewd
        chmod +x $YI_HACK_PREFIX/bin/rtspv4
    else
        cp -f "$TMP_FILE" "$YI_HACK_PREFIX/$FILE_TYPE"
    fi
fi

rm -f $TMP_FILE

printf "{\n"

printf "\"%s\":\"%s\"\n"  "error" "false"

printf "}"

exit 0
