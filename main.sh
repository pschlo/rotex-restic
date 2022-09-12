#!/bin/bash

# get directory where this script is located
ROOT=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

. "$ROOT/env.sh"


send_telegram () {
    echo -e "sending Telegram message"
    curl -X POST \
    --no-progress-meter \
    -H 'Content-Type: application/json' \
    -d "{\"chat_id\": $CHAT_ID, \"text\": \"${1}\"}" \
    https://api.telegram.org/bot$TOKEN/sendMessage
    echo -e "\n"
}

timestamp () {
    echo "$(date +"%Y-%m-%d %T")"
}

send_error () {
    send_telegram "❌ ${1}"
}

send_succ () {
    send_telegram "✅ ${1}"
}



echo -e "LOG $(timestamp)"
echo -e "----------------------------------------------------------------------------------------"

# check if rotex cloud is mounted
if ! [[ $(findmnt "$SOURCE_PATH") ]]
then
    echo -e "ERR: rotex cloud is not mounted"
    send_error "cloud is not mounted"
    exit
fi


echo -e "\n[$(timestamp)]\n--- STARTING BACKUP ---\n"
#restic backup --tag rotex_cloud $SOURCE_PATH

if [[ $? -eq 0 ]]
then
    send_succ "backup"
else
    send_error "backup"
fi


echo -e "\n\n[$(timestamp)]\n--- BACKUP FINISHED, CLEANING UP OLD BACKUPS ---\n"
sleep $DELAY
restic forget --tag $TAG --prune --keep-daily $KEEP_DAILY --keep-weekly $KEEP_WEEKLY --keep-monthly $KEEP_MONTHLY --keep-yearly $KEEP_YEARLY

if [[ $? -eq 0 ]]
then
    send_succ "forget"
else
    send_error "forget"
fi


echo -e "\n\n[$(timestamp)]\n--- OLD BACKUPS DELETED, CHECKING INTEGRITY ---\n"
sleep $DELAY
restic check

if [[ $? -eq 0 ]]
then
    send_succ "check"
else
    send_error "check"
fi
