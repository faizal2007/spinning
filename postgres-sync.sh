#!/bin/bash
#
# get config variable from file
#
Config() {
    echo `grep ${1} $(pwd)/conf/postgres.conf | grep -v '#'| cut -d '=' -f 2`
}

#
# sync require ssh keyless setup using root/postgres account
#

USER=`Config USER`
REMOTE=`Config REMOTE`
SOURCE=`Config SOURCE`
DESTINATION=`Config DESTINATION`

if [ -f $DESTINATION/postmaster.pid ];then
    systemctl stop postgresql.service
    rsync -cva --delete --inplace --exclude=*pg_xlog* --exclude=postmaster.pid $REMOTE:$SOURCE $DESTINATION
    systemctl start postgresql.service
    ss -tln
fi
