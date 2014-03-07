#!/bin/bash

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
