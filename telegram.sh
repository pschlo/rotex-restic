#!/bin/bash

EMOJI_RUNNING=⏳
EMOJI_OK=✅
EMOJI_FAIL=❌

# $1: message id
# $2: new text
edit_msg() {
    local res=$(
        curl -X POST \
        --no-progress-meter \
        -H 'Content-Type: application/json' \
        -d "{\"chat_id\": $CHAT_ID, \"message_id\": \"$1\", \"text\": \"$2\"}" \
        https://api.telegram.org/bot$BOT_TOKEN/editMessageText
    )

    if [[ $(echo $res | jq .ok) == true ]]; then
        echo "OK: telegram edit_msg \"$2\""
    else
        echo -e "ERROR: telegram edit_msg:\n$res"
    fi

}


# append to a message temporarily
# $1: message id
# $2: added message
append_msg_tmp() {
    local new_msg="$(cat $TMP/LAST_MSG.$1)\n$2"
    edit_msg "$1" "$new_msg"
    # do not overwrite LAST_MSG so that the task-running line gets overwritten with the task-done line
}

# append to a message permanently
append_msg_perm() {
    local new_msg="$(cat $TMP/LAST_MSG.$1)\n$2"
    edit_msg "$1" "$new_msg"
    # overwrite LAST_MSG to keep task-done line
    echo $new_msg > "$TMP/LAST_MSG.$1"
}

# $1: text
# $2: is_tmp (default false): When set to true, the initial message will be overwritten with next edit
# $3: return variable: see https://stackoverflow.com/a/38997681 and https://unix.stackexchange.com/a/615532
# returns message_id if successful, otherwise null
send_msg() {
    declare -n retval_send_msg=$3
    local res=$(
        curl -X POST \
        --no-progress-meter \
        -H 'Content-Type: application/json' \
        -d "{\"chat_id\": $CHAT_ID, \"text\": \"$1\"}" \
        https://api.telegram.org/bot$BOT_TOKEN/sendMessage
    )

    # check telegram server response
    local msg_id=
    if [[ $(echo $res | jq .ok) == true ]]; then
        msg_id=$(echo $res | jq .result.message_id)
        echo "OK: telegram send_msg \"$1\""
    else
        msg_id="null"
        echo -e "ERR: telegram send_msg:\n$res"
    fi

    # create LAST_MSG file
    if [[ $2 == "true" ]]; then
        # create/overwrite empty file
        > "$TMP/LAST_MSG.$msg_id"
    else
        # create/overwrite file with message
        echo $1 > "$TMP/LAST_MSG.$msg_id"
    fi

    retval_send_msg=$msg_id
}




### specific functions

# $1: return var to store msg_id
init_msg() {
    declare -n retval_init_msg=$1
    send_msg "Waiting for action" true retval_init_msg
}

# $1: msg id
# $2: task
set_running() {
    append_msg_tmp $1 "$EMOJI_RUNNING $2"
}

set_ok() {
    append_msg_perm $1 "$EMOJI_OK $2"
}

set_fail() {
    append_msg_perm $1 "$EMOJI_FAIL $2"
}

