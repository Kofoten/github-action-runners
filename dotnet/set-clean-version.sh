#!/bin/bash
set -e

CLEAN_VER=${GITHUB_REF_NAME#v}
echo "SEMVER=$CLEAN_VER" >> $GITHUB_ENV
echo "Set SEMVER=$CLEAN_VER"