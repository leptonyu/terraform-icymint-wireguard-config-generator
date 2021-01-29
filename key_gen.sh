#!/bin/bash
set -e
eval "$(jq -r '@sh "NAME=\(.name)"')"

mkdir .terraform || true

FILE=".terraform/wg_$NAME.key"
if [ ! -e "$FILE" ]; then
	KEY=$(wg genkey)
	PUB=$(echo "$KEY" | wg pubkey)
	jq -nrc ".pri=\"$KEY\" | .pub=\"$PUB\"" > $FILE
fi

cat $FILE

