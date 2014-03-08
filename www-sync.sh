#!/bin/bash

# Redirect file descriptor #3 to standard output (used in recordfailure)
exec 3>&1

# create an array for holding failures
declare -a failures

#
# rsync option
# Refer man rsync
#

OPTION="-azvv --progress --delete -e ssh"

#
# ssh authentication 
#
USER="user"
HOST="10.2.0.101"

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
NOWT=$(date +"%H%M-%S")

#
# @method to record error
#

function record_error() {
    local error retval

    if [ -d $LOGS ]; then
        # Run the command and store error messages (output to the standard error
        # stream in $error, but send regular output to file descriptor 3 which
        # redirects to standard output
        error="$("$@" 2>&1 /dev/null)"
        retval=$?
        # if the command failed (returned a non-zero exit code)
        if [ $retval -gt 0 ]; then
            if [ -z "$error" ]; then
                # create an error message if there was none
                error="Command failed with exit code $retval"
            fi
            # uncomment if you want the command in the error message
            #error="Command $* failed: $error"

            # append the error to $failures, ${#failures[@]} is the length of
            # the array and since array start at index 0, a new item is created
            failures[${#failures[@]}]="$error"
            # uncomment if you want to show the error immediately
            #echo "$error"
    fi
    else
        mkdir -p $LOGS
        logging
    fi

    if [ ${#failures[@]} -ne 0 ]; then
        echo "[FAIL]" 
        # list every error
        for failure in "${failures[@]}"
        do
            :
            # optionally color it, format it or whatever you want to do with it
            echo "error: $failure" > $LOGS"error-$NOW-$NOWT.log"  
        done
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

    #rsync $OPTION $EXCLUDE $USER@$HOST:$SOURCE $DESTINATION
    i=0
    for SOURCE in "${SOURCE[@]}"
    do
        :
        rsync $OPTION $EXCLUDE $USER@$HOST:$SOURCE ${DESTINATION[$i]}
    done
}

record_error st_sync
