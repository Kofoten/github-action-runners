#!/bin/bash
set -e

TARGET_VERSION="$GITHUB_REF_NAME"

# GitHub Actions requires writing to $GITHUB_ENV to pass variables between steps
echo "VERSION=$TARGET_VERSION" >> $GITHUB_ENV
          
HIGHEST_TAG=$(git tag -l "v*" | sort -V | tail -n 1)
          
echo "Pushed Tag: $TARGET_VERSION"
echo "Highest Tag in Repo: $HIGHEST_TAG"

if [ "$TARGET_VERSION" != "$HIGHEST_TAG" ]; then
    echo "ERROR: You pushed $TARGET_VERSION, but $HIGHEST_TAG already exists."
    echo "Release versions must strictly increase."
    exit 1
fi

echo "Version check passed."
