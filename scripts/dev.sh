#!/usr/bin/env bash
# Made by Jack'lul <jacklul.github.io>

#shellcheck disable=SC2155
readonly script_dir="$(dirname "$(readlink -f "$0")")"
readonly repository_core="https://github.com/pi-hole/pi-hole.git"
readonly repository_web="https://github.com/pi-hole/web.git"
readonly repository_ftl="https://github.com/pi-hole/FTL.git"
readonly repository_padd="https://github.com/pi-hole/PADD.git"

shallow=true
[ -f "$script_dir/../dev/noshallow" ] && shallow=false

#shellcheck disable=SC2086
function install_or_update_repository() {
    local repository="$1"
    local destination="$2"
    local new_branch="$3"
    local shallow_arg="--depth 1"

    if [ "$shallow" = false ]; then
        shallow_arg=
    fi

    echo "Working with repository: $repository"

    if [ ! -f "$destination/.git/config" ]; then
        mkdir -pv "$destination"
        git -C "$destination" init
        git -C "$destination" remote add origin "$repository"
        git -C "$destination" fetch $shallow_arg

        main_branch="$(git -C "$destination" remote show "$repository" | grep 'HEAD branch' | cut -d':' -f2 | tr -d ' ')"

        if [ -n "$new_branch" ]; then
            main_branch=$new_branch
        fi

        git -C "$destination" checkout "$main_branch"
        git -C "$destination" branch --set-upstream-to="origin/$main_branch"
    else
        local current_branch="$(git -C "$destination" rev-parse --abbrev-ref HEAD)"

        if [ -z "$new_branch" ]; then
            new_branch="$(git -C "$destination" remote show "$repository" | grep 'HEAD branch' | cut -d':' -f2 | tr -d ' ')"
        fi

        git -C "$destination" clean -fd

        if [ "$current_branch" = "$new_branch" ]; then
            git -C "$destination" fetch $shallow_arg
            git -C "$destination" reset --hard HEAD
            git -C "$destination" pull --rebase --allow-unrelated-histories $shallow_arg
        else
            git -C "$destination" fetch $shallow_arg
            git -C "$destination" checkout -f "$new_branch"
            git -C "$destination" branch --set-upstream-to="origin/$new_branch"
            git -C "$destination" reset --hard HEAD
        fi
    fi
}

##############

set -e

branch="$1"
repo=all
[ -n "$2" ] && repo="$2"

if [ ! -d "$script_dir/../dev" ]; then
    mkdir -pv "$script_dir/../dev"
fi

case $branch in
    "master"|"release")
        core_branch=master
        web_branch=master
        ftl_branch=master
        padd_branch=master
    ;;
    "dev")
        core_branch=development
        web_branch=development
        ftl_branch=development
        padd_branch=development
    ;;
    *)
        core_branch=$branch
        web_branch=$branch
        ftl_branch=$branch
        padd_branch=$branch
    ;;
esac

case $repo in
    all)
        install_or_update_repository "$repository_core" "$script_dir/../dev/core" "$core_branch"
        install_or_update_repository "$repository_web" "$script_dir/../dev/web" "$web_branch"
        install_or_update_repository "$repository_ftl" "$script_dir/../dev/FTL" "$ftl_branch"
        install_or_update_repository "$repository_padd" "$script_dir/../dev/PADD" "master"
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
    pad|PADD)
        install_or_update_repository "$repository_web" "$script_dir/../dev/PADD" "$padd_branch"
    ;;
    *)
        echo "Invalid repo selected, valid values: all, core, web, FTL"
        exit 1
    ;;
esac
