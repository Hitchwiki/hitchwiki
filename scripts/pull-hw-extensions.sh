#!/bin/bash

echo ""
echo "One script to pull 'em all..."
echo ""

cd $(dirname $0)/..

# Main repo
git pull origin master

# Do the extensions
cd extensions

# HitchwikiVector
cd HitchwikiVector
git pull origin master
bower update

# HWMaps
cd HWMap
git pull origin master
bower update

# HWComments
cd HWComments
git pull origin master

# HWRatings
cd HWRatings
git pull origin master

# HWWaitingTime
cd HWWaitingTime
git pull origin master

echo ""
echo "All done!"
