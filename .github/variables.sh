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
    VERSION="$GITHUB_REF_NAME"
elif [[ "$GITHUB_REF" =~ ^refs/pull/.* ]]; then
    VERSION="$GITHUB_REF_NAME-$(date +%s)"
elif [[ "$GITHUB_REF" =~ ^refs/heads/.* ]]; then
    VERSION="$(date +%Y.%m.%d)-$(date +%H%M%S)"

    if git rev-parse --is-inside-work-tree &>/dev/null; then
        VERSION="${VERSION}-$(git describe --always --abbrev=8)"
    fi
fi

[ -z "$VERSION" ] && { echo "Package version not set"; exit 1; }

# Clean version string
if ! echo "$VERSION" | grep -Eq '^[a-zA-Z0-9_.+-]+$'; then
    VERSION="${VERSION//[^a-zA-Z0-9_.+-]/-}"
fi

echo "VERSION=$VERSION" >> "$GITHUB_OUTPUT"

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

    {
        echo "CORE_REF=$CORE_REF"
        echo "WEB_REF=$WEB_REF"
        echo "FTL_REF=$FTL_REF"
    } >> "$GITHUB_OUTPUT"
else
    if [ -z "$CORE_DEV_BRANCH" ] || [ -z "$WEB_DEV_BRANCH" ] || [ -z "$FTL_DEV_BRANCH" ]; then
        echo "Development branches are not set"
        exit 1
    fi

    {
        echo "CORE_REF=$CORE_DEV_BRANCH"
        echo "WEB_REF=$WEB_DEV_BRANCH"
        echo "FTL_REF=$FTL_DEV_BRANCH"
    } >> "$GITHUB_OUTPUT"
fi
