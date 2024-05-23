#!/bin/bash
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
    VERSION="pull-$GITHUB_REF_NAME"
elif  [[ "$GITHUB_REF" =~ ^refs/heads/.* ]]; then
    VERSION="$(date +%Y.%m.%d)-$(date +%H%M%S)"

    # Special case for master branch
    if [ "$GITHUB_REF_NAME" = "master" ]; then
        LATEST_TAG="$(git ls-remote --tags --sort="v:refname" "https://github.com/$GITHUB_REPOSITORY" | tail -n1 | sed 's/.*\///; s/\^{}//')"
        [ -n "$LATEST_TAG" ] && VERSION="$LATEST_TAG"
    fi
fi

[ -z "$VERSION" ] && { echo "Package version not set"; exit 1; }
echo "VERSION=$VERSION" >> "$GITHUB_OUTPUT"

if [[ "$GITHUB_REF" =~ ^refs/tags/.* ]] || [ "$GITHUB_REF_NAME" = "master" ]; then
    {
        echo "CORE_REF=$CORE_HASH"
        echo "WEB_REF=$WEB_HASH"
        echo "FTL_REF=$FTL_HASH"
    } >> "$GITHUB_OUTPUT"
else
    {
        echo "CORE_REF=$CORE_BRANCH"
        echo "WEB_REF=$CORE_BRANCH"
        echo "FTL_REF=$CORE_BRANCH"
    } >> "$GITHUB_OUTPUT"
fi

cat "$GITHUB_OUTPUT"
