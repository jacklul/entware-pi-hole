#!/usr/bin/env bash
# Made by Jack'lul <jacklul.github.io>

#shellcheck disable=SC2155
readonly script_dir="$(dirname "$(readlink -f "$0")")"
readonly repository_core="https://github.com/pi-hole/pi-hole.git"
readonly repository_web="https://github.com/pi-hole/web.git"
readonly repository_ftl="https://github.com/pi-hole/FTL.git"

[ -f "$script_dir/../dev/.shallow" ] && shallow=true && echo "Shallow clone enabled"

#shellcheck disable=SC2086
function install_or_update_repository() {
    local repository="$1"
    local destination="$2"
    local new_branch="$3"
    local shallow_part=""

    echo "Working with repository: $repository"

    if [ ! -d "$destination" ]; then
        mkdir -pv "$destination"
    fi

    if [ "$shallow" = true ]; then
        shallow_part="--depth 1"
    fi

    if [ -z "$new_branch" ]; then
        new_branch="$(git -C "$destination" remote show "$repository" | grep 'HEAD branch' | cut -d':' -f2 | tr -d ' ')"
        echo "No branch specified, using remote HEAD branch: $new_branch"
    fi

    if [ ! -f "$destination/.git/config" ]; then
        git -C "$destination" init
        git -C "$destination" remote add origin "$repository"
        git -C "$destination" fetch $shallow_part
        git -C "$destination" checkout -b "$new_branch" --track "origin/$new_branch"
    else
        local current_branch="$(git -C "$destination" rev-parse --abbrev-ref HEAD)"

        git -C "$destination" clean -fd

        is_shallow=$(git -C "$destination" rev-parse --is-shallow-repository)

        if [ -z "$shallow_part" ]; then
            if [ "$is_shallow" = "true" ]; then
                git -C "$destination" fetch --unshallow
                git -C "$destination" gc --prune=now --aggressive
            else
                git -C "$destination" fetch
            fi
        else
            git -C "$destination" fetch $shallow_part

            if [ "$is_shallow" = "false" ]; then
                git -C "$destination" gc --prune=now --aggressive
            fi
        fi

        if [ "$current_branch" = "$new_branch" ]; then
            git -C "$destination" reset --hard HEAD
            git -C "$destination" pull --rebase --allow-unrelated-histories $shallow_part
        else
            if git -C "$destination" branch --list "$new_branch" | grep -Fq "$new_branch"; then
                git -C "$destination" checkout -f "$new_branch"
            else
                git -C "$destination" checkout -f -b "$new_branch" --track "origin/$new_branch"
            fi

            git -C "$destination" reset --hard HEAD
        fi
    fi
}

##############

set -e

branch="$1"
repo=all
[ -n "$2" ] && repo="$2"

case $branch in
    "master"|"release")
        core_branch=master
        web_branch=master
        ftl_branch=master
    ;;
    "development"|"dev")
        core_branch=development
        web_branch=development
        ftl_branch=development
    ;;
    *)
        core_branch=$branch
        web_branch=$branch
        ftl_branch=$branch
    ;;
esac

case $repo in
    all)
        install_or_update_repository "$repository_core" "$script_dir/../dev/core" "$core_branch"
        install_or_update_repository "$repository_web" "$script_dir/../dev/web" "$web_branch"
        install_or_update_repository "$repository_ftl" "$script_dir/../dev/FTL" "$ftl_branch"
    ;;
    core)
        install_or_update_repository "$repository_core" "$script_dir/../dev/core" "$core_branch"
    ;;
    web)
        install_or_update_repository "$repository_web" "$script_dir/../dev/web" "$web_branch"
    ;;
    ftl|FTL)
        install_or_update_repository "$repository_ftl" "$script_dir/../dev/FTL" "$ftl_branch"
    ;;
    *)
        echo "Invalid repo selected, valid values: all, core, web, FTL"
        exit 1
    ;;
esac
