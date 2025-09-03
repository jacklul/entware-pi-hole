#!/usr/bin/env bash
# Made by Jack'lul <jacklul.github.io>

#shellcheck disable=SC2155
readonly script_dir="$(dirname "$(readlink -f "$0")")"
prefix="$1"
target="$2"

if [ -z "$prefix" ] || [ -z "$target" ] || [ ! -d "$target" ]; then
    echo "Usage: $0 <file prefix> <repository path> [no-patches/no-checks]"
    exit 1
fi

prefix="${prefix,,}" # Force prefix to be lowercase
target="$(realpath "$target")"
branch=$(git -C "$target" rev-parse --abbrev-ref HEAD)
tag=$(git -C "$target" describe --tags --always 2> /dev/null)

echo "Branch: $branch"
echo "Tag: $tag"
echo

# If we are on a detached HEAD and the tag is not matching a tag with a -gHASH suffix then assume master
if [ "$branch" = "HEAD" ] && [ -n "$tag" ] && ! grep -Eq '\-[gG][0-9a-fA-F]+$' <<< "$tag"; then
    branch="master"
    echo "Release tag detected, assuming branch 'master'"
fi

if [ "$3" != "no-patches" ]; then
    patches_dir="$(readlink -f "$script_dir/../patches")"

    # Use development patches when there are no patches for the current branch (excluding master)
    if [ "$branch" != "master" ] && [ ! -d "$patches_dir/$branch" ]; then
        branch="development"
    fi

    files="$(find "$patches_dir" -maxdepth 1 -type f \( -name "$prefix-*.patch" -or -name "$prefix-*.diff" \) | sort)"
    for file in $files; do
        basename="$(basename "$file")"

        # if the same file exists in BRANCH subdirectory then use it instead
        if [ -f "$patches_dir/$branch/$basename" ]; then
            file="$patches_dir/$branch/$basename"
        fi

        if [ ! -s "$file" ]; then
            echo "Patch file $file is empty, skipping"
            echo ""
            continue
        fi

        echo "Applying patch file: $file"
        git -C "$target" apply -v "$file" || exit 1
        echo ""
    done

    files="$(find "$patches_dir" -maxdepth 1 -type f -name "$prefix-*.sh" | sort)"
    for file in $files; do
        basename="$(basename "$file")"

        # if the same file exists in BRANCH subdirectory then use it instead
        if [ -f "$patches_dir/$branch/$basename" ]; then
            file="$patches_dir/$branch/$basename"
        fi

        if [ ! -s "$file" ]; then
            echo "Patch script $file is empty, skipping"
            echo ""
            continue
        fi

        echo "Running patch script: $file"
        bash "$file" "$target" || exit 1
        echo ""
    done

    echo "All patches applied"
    echo ""
fi

if [ "$3" != "no-checks" ]; then
    checks_dir="$(readlink -f "$script_dir/../checks")"

    files="$(find "$checks_dir" -maxdepth 1 -type f -name "$prefix-*.sh" | sort)"
    for file in $files; do
        echo "Running check script: $file"
        bash "$file" "$target" || exit 1
        echo ""
    done

    echo "All checks passed"
    echo ""
fi

exit 0
