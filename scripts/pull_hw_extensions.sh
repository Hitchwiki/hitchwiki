#!/bin/bash

#
# Fast trimmed down extension update script for dev environment:
# pull HitchwikiVector, HWMap, HWComments, HWRatings, HWWaitingTime extensions
# and update their frontend assets
#
# Relies on "git stash" and "git stash pop" to preserve local changes made to
# extension files
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
echo "Pull main repo..."
cd "$ROOTDIR"
git stash
git pull origin master
git stash pop
echo

# HitchwikiVector
echo "Pull HitchwikiVector repo..."
cd "$ROOTDIR/extensions/HitchwikiVector"
git stash
git pull origin master
git stash pop
echo
bower update
echo

# HWMaps
echo "Pull HWMap repo..."
cd "$ROOTDIR/extensions/HWMap"
git stash
git pull origin master
git stash pop
echo
bower update
echo

# HWComments
echo "Pull HWComments repo..."
cd "$ROOTDIR/extensions/HWComments"
git stash
git pull origin master
git stash pop
echo

# HWRatings
echo "Pull HWRatings repo..."
cd "$ROOTDIR/extensions/HWRatings"
git stash
git pull origin master
git stash pop
echo

# HWWaitingTime
echo "Pull HWWaitingTime repo..."
cd "$ROOTDIR/extensions/HWWaitingTime"
git stash
git pull origin master
git stash pop
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
