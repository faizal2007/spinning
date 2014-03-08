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
# DB config
# 1 - sync all (Make sure default local server password to run mysql-server 
#     have the same password with source server other mysql-server will failed to run)
# 2 - sync all ignore default db mysql,information_schema
# 3 - sync selected db
#

SYNC=1

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
            *)
            echo $"Usage : $0 {1|2|3}. Initialize var SYNC with correct value." 
            exit 1
   esac
   
   # dump mysql from source to destination server
   mysqldump --defaults-extra-file=$RCONF $OPT $DB_LIST > "$TMP/db.sql"
   mysql --defaults-extra-file=$LCONF < "$TMP/db.sql"
   
   # fix mysql when all database dump
   [[ $1 -eq 1 ]] && mysql_upgrade --defaults-extra-file=$LCONF --force 
}


sync_db $SYNC
