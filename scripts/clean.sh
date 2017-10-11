#!/bin/bash

#
# Hitchwiki cleaning installation script
#

set -e

source "scripts/_path_resolve.sh"

# Remove Mediawiki folder
rm -rf "$WIKIDIR"

# Other folders or files created by installation
rm "$ROOTDIR/composer.lock"
rm -fr "$ROOTDIR/html"
rm -fr "$ROOTDIR/public/composer"

# Remove log files
rm "$ROOTDIR/scripts/*-cloudimg-console.log"
rm "$ROOTDIR/*-cloudimg-console.log"
