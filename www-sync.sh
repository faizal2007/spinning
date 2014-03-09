#!/bin/bash

#
# Script to sync Directory
#

#
# rsync option
# Refer man rsync
#

OPTION="-azvv --progress --delete -e ssh"

#
# ssh authentication 
#
USER="user"
HOST="102.2.0.101"

#
# Server Setting
#

## Production Server
SOURCE[0]="/var/www/"
SOURCE[1]="/var/storage/"

## Local Server
DESTINATION[0]="/home/local/web/"
DESTINATION[1]="/home/local/lib/"

## Exclude File
## Split file by <space>
## Comment EXCLUDE_FILE to sync all
EXCLUDE_FILE[0]="configuration.php"
#EXCLUDE_FILE[1]="smnd/index.php"

#
# Log
#
LOGS="/var/log/www-sync/"
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
        rsync $OPTION $EXCLUDE $USER@$HOST:$SOURCE ${DESTINATION[$i]}
        i=$[i+1]
    done
}

## Starting to sync data
record_error st_sync
