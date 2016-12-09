#!/bin/bash

#
# Fast trimmed down extension update script for dev environment:
# pull HitchwikiVector, HWMap, HWComments, HWRatings, HWWaitingTime extensions
# and update their frontend assets
#
# For a proper update, including backend dependencies, MediaWiki and third-party
# extensions, use update.sh (or its wrapper vagrant_update.sh) instead
#

echo
echo "One script to pull 'em all..."
echo

cd "$(dirname $0)/.."

# Main repo
git pull origin master

# Do the extensions
cd extensions

# HitchwikiVector
cd HitchwikiVector
git pull origin master
bower update

# HWMaps
cd ../HWMap
git pull origin master
bower update

# HWComments
cd ../HWComments
git pull origin master

# HWRatings
cd ../HWRatings
git pull origin master

# HWWaitingTime
cd ../HWWaitingTime
git pull origin master


cd ../../
echo
echo "Run post-install-cmd for HWMap extension..."
composer run-script post-update-cmd -d ./extensions/HWMap
echo
echo "Run post-install-cmd for HitchwikiVector extension..."
composer run-script post-update-cmd -d ./extensions/HitchwikiVector
echo
echo "Run post-install-cmd for HWRatings extension..."
composer run-script post-update-cmd -d ./extensions/HWRatings
echo
echo "-------------------------------------------------------------------------"


echo
echo "All done!"
