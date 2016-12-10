#!/bin/bash

#
# Constantly process MediaWiki job queue until interruped
#
# [!] Puts server under heavy pressure; use with caution
#

if [ ! -f Vagrantfile ]; then # an arbirtrary file that appears only once in the whole repository tree
    echo "ERROR: Bad working directory ($(pwd))."
    echo "Scripts have to be run from the root directory of the hitchwiki repository."
    echo "Aborting."
    exit 1
fi

source "scripts/_path_resolve.sh"

echo "Process MediaWiki job queue till eternity..."
echo

cd "$WIKIDIR"
while true; do
	php maintenance/runJobs.php
	sleep 10
done
