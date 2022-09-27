#!/bin/bash
# this script should be dot sourced with variables set

# EXIT CODES
# 1: restic backup failed
# 2: restic foget failed
# 3: restic check failed
# 10: source dir not mounted


# export restic env vars
export RESTIC_REPOSITORY=$BACKUP_DIR
export RESTIC_PASSWORD=$BACKUP_PASSWORD


echo -e "LOG $(timestamp)"
echo -e "----------------------------------------------------------------------------------------"

# check if rotex cloud is mounted
if ! [[ $(findmnt "$SOURCE_DIR") ]]; then return 10; fi


echo -e "\n[$(timestamp)]\n--- STARTING BACKUP ---\n"
restic backup --tag rotex_cloud $SOURCE_DIR
if [[ $? -ne 0 ]]; then return 1; fi


echo -e "\n\n[$(timestamp)]\n--- BACKUP FINISHED, CLEANING UP OLD BACKUPS ---\n"
sleep $DELAY
restic forget --tag $TAG --group-by tags --prune --keep-daily $KEEP_DAILY --keep-weekly $KEEP_WEEKLY --keep-monthly $KEEP_MONTHLY --keep-yearly $KEEP_YEARLY
if [[ $? -ne 0 ]]; then return 2; fi


echo -e "\n\n[$(timestamp)]\n--- OLD BACKUPS DELETED, CHECKING INTEGRITY ---\n"
sleep $DELAY
restic check
if [[ $? -ne 0 ]]; then return 3; fi
