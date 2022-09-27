#!/bin/bash

# get directory where this script is located
ROOT=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

# import variables and functions
for f in "$ROOT/env/"*.sh; do source $f; done
source "$ROOT/utils.sh"
source "$ROOT/telegram.sh"

# create tmp dir
mkdir -p "$TMP"

# initialize telegram output
msg_id=
init_msg msg_id



# run cloud backup
set_running $msg_id "cloud"
source "$ROOT/cloud-backup.sh"
exit_code=$?

# analyze exit code
if [[ $exit_code -eq 0 ]]; then
   set_ok $msg_id "cloud"
else
    case $exit_code in
        1) msg="backup failed";;
        2) msg="forget failed";;
        3) msg="check failed";;
        10) msg="source not mounted";;
        *) msg="unknown error";;
    esac
    set_fail $msg_id "cloud: $msg"
fi

exit



# run bitwarden backup
set_running $msg_id "bitwarden"
source "$ROOT/bitwarden-backup.sh"

if [[ $? -eq 0 ]]; then
    set_ok $msg_id "bitwarden"
else
    set_fail $msg_id "bitwarden"
fi


# remove tmp files
rm -r "$TMP"
