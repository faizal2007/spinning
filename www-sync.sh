#!/bin/bash
#
# get config variable from file
#
Config() {
    echo `grep ${1} $(pwd)/conf/file.conf | grep -v '#'| cut -d '=' -f 2`
}

#
# Script to sync Directory
#

exec 3>&1

#
# rsync option
# Refer man rsync
#

OPTION=`Config OPTION`

#
# ssh authentication 
#
USER=`Config USER`
HOST=`Config REMOTE`

#
# Server Setting
#

## Production Server
SOURCE=`Config SOURCE`

## Local Server
DESTINATION=`Config DESTINATION`

## Exclude File
## Split file by <space>
## Comment EXCLUDE_FILE to sync all
EXCLUDE_FILE=`Config EXCLUDE_FILE`

SOURCE=($SOURCE)
DESTINATION=($SOURCE)
EXCLUDE_FILE=($SOURCE)

#
# Log
#
LOGS=`Config LOGS`
## date format ##
NOW=$(date +"%F")
NOWT=$(date +"%T")


###
#
# Core Script
#
###

#
# @method to record error
#

function record_error() {
    local error
    
    # create folder & redirect error to variable
    # replace 1>/dev/null with >&3 to view standard output
    if [ -d $LOGS ]; then
        error="$("$@" 2>&1 1>/dev/null)"
    else
        mkdir -p $LOGS
        record_error "$@"
    fi
    
   # writing error log
    if [ "$error" ]; then
        echo "[FAIL] -- $NOW $NOWT" | tee >> $LOGS"error.log"
        echo $error | tee >> $LOGS"error.log"
        echo "[END]" >> $LOGS"error.log"
    fi
}

#
# @method to sync directory and file
#

function st_sync() {
    if [ ${#EXCLUDE_FILE[@]} -eq 0 ]; then
        EXCLUDE=""
    else
        for FILE in "${EXCLUDE_FILE[@]}"
        do
            :
            EXCLUDE=$EXCLUDE"--exclude $FILE "
        done 
    fi
    
    ## Sync multiple source
    i=0
    for SOURCE in "${SOURCE[@]}"
    do
        :
        file=`echo $SOURCE | sed 's/^\///' | sed 's#/$##' | sed 's#/#-#g'`
        rsync $OPTION $EXCLUDE $USER@$HOST:$SOURCE ${DESTINATION[$i]} | tee $LOGS/$file.log
        i=$[i+1]
    done
}

## Starting to sync data
record_error st_sync

