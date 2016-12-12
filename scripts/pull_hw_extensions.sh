#!/bin/bash

#
# Fast trimmed down extension update script for dev environment:
# pull HitchwikiVector, HWMap, HWComments, HWRatings, HWWaitingTime extensions
# and update their frontend assets
#
# For a proper update, including backend dependencies, MediaWiki and third-party
# extensions, use update.sh (or its wrapper vagrant_update.sh) instead
#

if [ ! -f Vagrantfile ]; then # an arbirtrary file that appears only once in the whole repository tree
    echo "ERROR: Bad working directory ($(pwd))."
    echo "Scripts have to be run from the root directory of the hitchwiki repository."
    echo "Aborting."
    exit 1
fi

source "scripts/_path_resolve.sh"

echo
echo "Update Hitchwiki's in-house extensions..."
echo

# Main repo
cd "$ROOTDIR"
git pull origin master
echo

# HitchwikiVector
cd "$ROOTDIR/extensions/HitchwikiVector"
git pull origin master
echo
bower update
echo

# HWMaps
cd "$ROOTDIR/extensions/HWMap"
git pull origin master
echo
bower update
echo

# HWComments
cd "$ROOTDIR/extensions/HWComments"
git pull origin master
echo

# HWRatings
cd "$ROOTDIR/extensions/HWRatings"
git pull origin master
echo

# HWWaitingTime
cd "$ROOTDIR/extensions/HWWaitingTime"
git pull origin master
echo

echo "Run post-install-cmd for HWMap extension..."
cd "$ROOTDIR"
composer run-script post-update-cmd -d ./extensions/HWMap

echo
echo "Run post-install-cmd for HitchwikiVector extension..."
cd "$ROOTDIR"
composer run-script post-update-cmd -d ./extensions/HitchwikiVector

echo
echo "Run post-install-cmd for HWRatings extension..."
cd "$ROOTDIR"
composer run-script post-update-cmd -d ./extensions/HWRatings

echo
echo "All in-house extensions updated!"
