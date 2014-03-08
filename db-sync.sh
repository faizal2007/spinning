#!/bin/bash

#
# Script to sync mysql data
#

#
# Include config file for authentication
#

CONF_DIR=/etc/mysql/

## Remote Server auth conf
CONF_FILE[0]="db-sync.conf"

## Local Server auth conf
CONF_FILE[1]="db-sync-local.conf"

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

