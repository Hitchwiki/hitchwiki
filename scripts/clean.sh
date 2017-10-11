#!/bin/bash

#
# Hitchwiki cleaning installation script
#

set -e

source "scripts/_path_resolve.sh"

echo ""
echo "Cleaning up files and folders created by Hitchwiki install..."

# Remove Mediawiki folder
rm -fr "$WIKIDIR"

# Other folders or files created by installation
rm -f "$ROOTDIR/composer.lock"
rm -fr "$ROOTDIR/public/composer"

# Remove log files
rm -f "$ROOTDIR/*-cloudimg-console.log"
rm -f "$ROOTDIR/scripts/*-cloudimg-console.log"

echo "Done! Note that this did not remove config files:"
echo "- ./configs/settings.ini"
echo "- ./configs/vagrant.yaml"
echo ""
