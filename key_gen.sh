#!/bin/bash
set -e
eval "$(jq -r '@sh "NAME=\(.name) KEY_PATH=\(.path)"')"

mkdir -p $KEY_PATH || true

FILE="$KEY_PATH/$NAME.key"
if [ ! -e "$FILE" ]; then
	KEY=$(wg genkey)
	PUB=$(echo "$KEY" | wg pubkey)
	jq -nrc ".pri=\"$KEY\" | .pub=\"$PUB\"" > $FILE
fi

cat $FILE