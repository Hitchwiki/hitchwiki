#!/bin/bash

#
# Hitchwiki cleaning installation script
#

#set -e # allow to run multiple times

source "scripts/_path_resolve.sh"

echo ""
echo "Cleaning up files and folders created by Hitchwiki install..."

# Remove ansible state
rm ./group_vars/state

# Remove Mediawiki folder
rm -fr "$WIKIDIR"

# Other folders or files created by installation
rm -f "$ROOTDIR/composer.lock"
rm -fr "$ROOTDIR/public/composer"

# Remove log files
rm -f "$ROOTDIR/*-cloudimg-console.log"
rm -f "$ROOTDIR/scripts/*-cloudimg-console.log"

# Remove vagrant box
vagrant destroy -f

echo "Done! Note that this did not remove config files:"
echo "- ./configs/settings.yml"
echo "- ./configs/vagrant.yaml"
echo ""
