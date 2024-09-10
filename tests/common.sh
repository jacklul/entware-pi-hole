#!/usr/bin/env bash

if [ -z "$1" ]; then
    echo "TARGET_DIR is not set"
    exit 1
fi

#shellcheck disable=SC2155,SC2034
readonly TARGET_DIR="$(readlink -f "$1")"
