#!/usr/bin/env bash
# Made by Jack'lul <jacklul.github.io>

[ -z "$GITHUB_OUTPUT" ] && { echo "GITHUB_OUTPUT is not set"; exit 1; }
[ -z "$GITHUB_EVENT_NAME" ] && { echo "GITHUB_EVENT_NAME is not set"; exit 1; }
[ -z "$GITHUB_REF" ] && { echo "GITHUB_REF is not set"; exit 1; }
[ -z "$GITHUB_REF_NAME" ] && { echo "GITHUB_REF_NAME is not set"; exit 1; }

# Scheduled runs build develop package
if [ "$GITHUB_EVENT_NAME" = "schedule" ]; then
    GITHUB_REF_NAME="develop"
    GITHUB_REF="refs/heads/develop"
fi

if [[ "$GITHUB_REF" =~ ^refs/tags/.* ]]; then
    version="$GITHUB_REF_NAME"
elif [[ "$GITHUB_REF" =~ ^refs/pull/.* ]]; then
    version="$GITHUB_REF_NAME-$(date +%s)"
elif [[ "$GITHUB_REF" =~ ^refs/heads/.* ]]; then
    version="$(date +%Y.%m.%d)-$(date +%H%M%S)"

    if git rev-parse --is-inside-work-tree &>/dev/null; then
        version="${version}-$(git describe --always --abbrev=8)"
    fi
fi

[ -z "$version" ] && { echo "Package version not set"; exit 1; }

# Clean version string
if ! echo "$version" | grep -Eq '^[a-zA-Z0-9_.+-]+$'; then
    version="${version//[^a-zA-Z0-9_.+-]/-}"
fi

echo "VERSION=$version" >> "$GITHUB_OUTPUT"

if [[ "$GITHUB_REF" =~ ^refs/tags/.* ]] || [ "$GITHUB_REF_NAME" = "master" ]; then
    if [ -z "$CORE_REF" ] || [ -z "$WEB_REF" ] || [ -z "$FTL_REF" ]; then
        # Special case for master branch
        if [ "$GITHUB_REF_NAME" = "master" ]; then
            CORE_REF=$CORE_BRANCH
            WEB_REF=$WEB_BRANCH
            FTL_REF=$FTL_BRANCH
        fi

        if [ -z "$CORE_REF" ] || [ -z "$WEB_REF" ] || [ -z "$FTL_REF" ]; then
            echo "Release refs are not set"
            exit 1
        fi
    fi
else
    if [ -z "$CORE_DEV_BRANCH" ] || [ -z "$WEB_DEV_BRANCH" ] || [ -z "$FTL_DEV_BRANCH" ]; then
        echo "Development branches are not set"
        exit 1
    fi

    CORE_REF=$CORE_DEV_BRANCH
    WEB_REF=$WEB_DEV_BRANCH
    FTL_REF=$FTL_DEV_BRANCH
fi

[ -n "$CORE_REF_OVERRIDE" ] && CORE_REF="$CORE_REF_OVERRIDE"
[ -n "$WEB_REF_OVERRIDE" ] && WEB_REF="$WEB_REF_OVERRIDE"
[ -n "$FTL_REF_OVERRIDE" ] && FTL_REF="$FTL_REF_OVERRIDE"

{
    echo "CORE_REF=$CORE_REF"
    echo "WEB_REF=$WEB_REF"
    echo "FTL_REF=$FTL_REF"
} >> "$GITHUB_OUTPUT"
