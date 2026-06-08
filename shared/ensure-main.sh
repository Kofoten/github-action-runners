#!/bin/bash
set -e

git fetch origin main

if git merge-base --is-ancestor "$GITHUB_REF_NAME" origin/main; then
    echo "Tag $GITHUB_REF_NAME is on the main branch."
else
    echo "ERROR: Tag $GITHUB_REF_NAME is NOT on the main branch!"
    echo "Releases can only be created from commits on main."
    exit 1
fi
