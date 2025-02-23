#!/usr/bin/env bash
# Made by Jack'lul <jacklul.github.io>

#shellcheck disable=SC2155
readonly SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
readonly REPO_CORE="https://github.com/pi-hole/pi-hole.git"
readonly REPO_WEB="https://github.com/pi-hole/web.git"
readonly REPO_FTL="https://github.com/pi-hole/FTL.git"

function install_or_update_repository() {
    local REPOSITORY="$1"
    local DESTINATION="$2"
    local NEW_BRANCH="$3"

    echo "Working with repository: $REPOSITORY"

    if [ ! -f "$DESTINATION/.git/config" ]; then
        mkdir -pv "$DESTINATION"
        git -C "$DESTINATION" init
        git -C "$DESTINATION" remote add origin "$REPOSITORY"
        git -C "$DESTINATION" fetch --depth 1

        MAIN_BRANCH="$(git -C "$DESTINATION" remote show "$REPOSITORY" | grep 'HEAD branch' | cut -d':' -f2 | tr -d ' ')"

        if [ -n "$NEW_BRANCH" ]; then
            MAIN_BRANCH=$NEW_BRANCH
        fi

        git -C "$DESTINATION" checkout "$MAIN_BRANCH"
        git -C "$DESTINATION" branch --set-upstream-to="origin/$MAIN_BRANCH"
    else
        local CURRENT_BRANCH="$(git -C "$DESTINATION" rev-parse --abbrev-ref HEAD)"

        if [ -z "$NEW_BRANCH" ]; then
            NEW_BRANCH="$(git -C "$DESTINATION" remote show "$REPOSITORY" | grep 'HEAD branch' | cut -d':' -f2 | tr -d ' ')"
        fi

        git -C "$DESTINATION" clean -fd

        if [ "$CURRENT_BRANCH" = "$NEW_BRANCH" ]; then
            git -C "$DESTINATION" fetch
            git -C "$DESTINATION" reset --hard HEAD
            git -C "$DESTINATION" pull --rebase --depth 1 --allow-unrelated-histories
        else
            git -C "$DESTINATION" fetch --depth 1
            git -C "$DESTINATION" checkout -f "$NEW_BRANCH"
            git -C "$DESTINATION" branch --set-upstream-to="origin/$NEW_BRANCH"
        fi
    fi
}

##############

set -e

BRANCH="$1"
REPO=all
[ -n "$2" ] && REPO="$2"

if [ ! -d "$SCRIPT_DIR/../dev" ]; then
    mkdir -pv "$SCRIPT_DIR/../dev"
fi

case $BRANCH in
    "dev")
        CORE_BRANCH=development
        WEB_BRANCH=development
        FTL_BRANCH=development
    ;;
    *)
        CORE_BRANCH=$BRANCH
        WEB_BRANCH=$BRANCH
        FTL_BRANCH=$BRANCH
    ;;
esac

case $REPO in
    all)
        install_or_update_repository "$REPO_CORE" "$SCRIPT_DIR/../dev/core" "$CORE_BRANCH"
        install_or_update_repository "$REPO_WEB" "$SCRIPT_DIR/../dev/web" "$WEB_BRANCH"
        install_or_update_repository "$REPO_FTL" "$SCRIPT_DIR/../dev/FTL" "$FTL_BRANCH"
    ;;
    core)
        install_or_update_repository "$REPO_CORE" "$SCRIPT_DIR/../dev/core" "$CORE_BRANCH"
    ;;
    web)
        install_or_update_repository "$REPO_WEB" "$SCRIPT_DIR/../dev/web" "$WEB_BRANCH"
    ;;
    ftl|FTL)
        install_or_update_repository "$REPO_FTL" "$SCRIPT_DIR/../dev/FTL" "$FTL_BRANCH"
    ;;
    *)
        echo "Invalid repo selected, valid values: all, core, web, FTL"
        exit 1
    ;;
esac
