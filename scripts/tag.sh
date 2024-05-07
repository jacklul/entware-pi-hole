#!/bin/bash
# Made by Jack'lul <jacklul.github.io>

REVISION=0
TAG=""
LIMIT=100

while [ "$TAG" = "" ] || git tag | grep -q "$TAG"; do
    REVISION=$((REVISION+1))
    TAG=$(date +%Y.%m.%d)-$REVISION

    LIMIT=$((LIMIT-1))
    if [ $LIMIT -le 0 ]; then
        exit 1
    fi
done

echo "$TAG"
