#!/bin/bash

#
# Script to sync mysql data
#

#
# Include config file for authentication
#

CONF_DIR="/etc/mysql/"

## Remote Server auth conf
CONF_FILE[0]="db-sync.conf"

## Local Server auth conf
CONF_FILE[1]="db-sync-local.conf"

#
# Log
#
LOGS="/var/log/db-sync/"
## date format ##
NOW=$(date +"%F")
NOWT=$(date +"%T")

#
# DB config
# 1 - sync all (Make sure default local server password to run mysql-server 
#     have the same password with source server other mysql-server will failed to run)
# 2 - sync all ignore default db mysql,information_schema
# 3 - sync selected db
#
SYNC=1

## Selected DB
DB="bola tanknkinis"

#
# Core script
#

# Initiate config file full path
## CONF_FILE Array size must equal to 2
[[ ${#CONF_FILE[@]} -ne 2 ]] && { echo "CONF_FILE must equal to 2. Lesser or more config are not allowed" ; exit; }

## Remote conf
[[ -r $CONF_DIR${CONF_FILE[0]} ]] && RCONF=$CONF_DIR${CONF_FILE[0]} || RCONF="./${CONF_FILE[0]}"

## Local conf
[[ -r $CONF_DIR${CONF_FILE[1]} ]] && LCONF=$CONF_DIR${CONF_FILE[1]} || LCONF="./${CONF_FILE[1]}"


# Temporary dump staging folder
  TMP=$(mktemp -d -t tmp.XXXXXXXXXX)
#
# @method to delete Temporary folder
#
function finish {
  rm -rf "$TMP"
}
trap finish EXIT

#
# @method log error
#
function record_error() {
    if [ -d $LOGS ]; then
        echo "[FAIL] -- $NOW $NOWT" | tee >> $LOGS"error.log"
        eval "$@" 2>&1 | tee >> $LOGS"error.log" 
        echo "[END]" | tee >> $LOGS"error.log"
    else
        mkdir -p $LOGS
        record_error "$@"
    fi
}


#
# @method Sync db
#

function sync_db() {

    # switch to available type
    # only 3 option available
    
    case "$1" in
            1)
            OPT="--events  --skip-add-locks --databases"
            DB_LIST=$(mysql --defaults-extra-file=$RCONF -NBe 'SHOW SCHEMAS' | grep -wv 'information_schema\|performance_schema')
            ;;
            2)
            OPT="--databases"
            DB_LIST=$(mysql --defaults-extra-file=$RCONF -NBe 'SHOW SCHEMAS' | grep -wv 'mysql\|information_schema\|performance_schema')
            ;;
            3)
            OPT="--databases"
            DB_LIST=$DB
            ;;
            *)
            echo $"Usage : $0 {1|2|3}. Initialize var SYNC with correct value." 
            exit 1
   esac

    # Initiate list of local  db without 'mysql', 'information_schema', 'performance_schema'
    DBL_LIST=$(mysql --defaults-extra-file=$LCONF -NBe 'SHOW SCHEMAS' | grep -wv 'mysql\|information_schema\|performance_schema')
    # Drop all local db except mysql to make sure data in source db are the same with  
    # destination db
    
    if [ "$DBL_LIST" ]; then
        for db in $(echo "$DBL_LIST")
        do
        :
        mysql --defaults-extra-file=$LCONF -e "DROP DATABASE $db"
        done
    fi

    # dump mysql from source to destination server
    mysqldump --defaults-extra-file=$RCONF $OPT $DB_LIST > "$TMP/db.sql"
    mysql --defaults-extra-file=$LCONF < "$TMP/db.sql"

    # fix mysql privileges when all database dump
    if [ $1 -eq 1 ]; then
        mysql_upgrade --defaults-extra-file=$LCONF --force &> "/var/log/mysql-upgrade.log"
    fi
}

record_error sync_db $SYNC




