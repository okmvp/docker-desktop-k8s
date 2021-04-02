#!/bin/sh
export ENCPW=$(htpasswd -nbBC 10 "" "$1" | tr -d ':\n' | sed 's/$2y/$2a/')
export MTIME=$2
#export MTIME=$(date -u +%FT%TZ)
echo "{ \"encpw\": \"$ENCPW\", \"mtime\": \"$MTIME\" }"

