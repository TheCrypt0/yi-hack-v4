#!/bin/sh

# source env
APP_HOME=`dirname $0`/..
. $APP_HOME/etc/push.conf

# private key
KEY=$APP_HOME/.ssh/transfer-key

# dest server
SERVER=${DEST_USER}@${DEST_HOST}

# path to recordings
BASE=/tmp/sd/record
DAY=`date +%YY%mM%dD`
HOUR=`date +%H`
NOW=${DAY}${HOUR}H
MIN=`date +%M`
RECORD_PATH=$BASE/${DAY}${HOUR}H
if [ $MIN -gt 50 ]; then
  # Each minute files are written, wait if at the end of the hour to capture all
  sleep $((61-$MIN))m
fi

usage() {
    echo
    echo "Usage: $0 -f [filepath] -h -t [datepath]"
    echo "Where:"
    echo "  -f = filename path, eg: -f /tmp/log.txt"
    echo "  -h = publish all for the hour"
    echo "  -t = target hour, eg: $NOW"
    echo
    exit 1
}

if [ "_$1" = "_" ]; then
  usage
fi

# parse options
file=
target_path=
while getopts "f:t:h" o; do
  case "$o" in
    f) file="$OPTARG";;
    t) file="$BASE/$OPTARG"; target_path="$OPTARG/";;
    h) file=$RECORD_PATH; target_path=$NOW/;;
    [?]) usage
  esac
done


#########################
# functions
#########################

check_exists() {
  if [ ! -e $file ]; then
    echo
    echo "WARN: File [ $file ] does not exist"
    echo
    exit 1
  fi
}

check_filesize() {
  local=`ls -l $1 | awk '{print $5}'`
  remote=`ssh -i $KEY $SERVER ls -l $DEST_PATH/$target_path/$2 2>/dev/null | awk '{print $5}'`

  if [ "_$local" = "_$remote" ]; then
    return 0
  else
    return 1
  fi
}

do_batch_scp() {
  rm -f /tmp/remote.* /tmp/local.*
  ssh -i $KEY $SERVER ls -l $DEST_PATH/$target_path/ 2>/dev/null | awk '{print $5,$9}' > /tmp/remote.$$
  if [ $? -ne 0 ]; then
    return
  fi
  ls -l $file | awk '{print $5,$9}' > /tmp/local.$$

  for i in `cat /tmp/local.$$ | awk '{print $2}'`; do
    local_file=`cat /tmp/local.$$ | grep $i | awk '{print $1}'`
    remote_file=`cat /tmp/remote.$$ | grep $i | awk '{print $1}'`
    if [ "_$local_file" = "_$remote_file" ]; then
      echo "INFO: Skipping [ $i ] File exists on remote"
    else
      do_scp $file/$i 0
    fi
  done
}

do_mkdir() {
  ssh -i $KEY $SERVER mkdir -p $DEST_PATH/$target_path
}

do_scp() {
  if [ "_$2" = "_0" ]; then
    echo "INFO: Copying [ $1 ]"
    scp -i $KEY $1 $SERVER:$DEST_PATH/$target_path
  else
    filename=`echo $1 | sed "s/.*\///"`
    check_filesize $1 $filename
    if [ $? -ne 0 ]; then
      echo "INFO: Copying file [ $1 ]"
      scp -i $KEY $1 $SERVER:$DEST_PATH/$target_path
    else
      echo "INFO: Skipping [ $1 ] File exists on remote"
    fi
  fi
}

# main function
main() {
  check_exists $file
  if [ -d $file ]; then
    do_mkdir
    do_batch_scp
  else
    do_scp $file
  fi
}

# run!
main