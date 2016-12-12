#!/bin/bash

#
# Process MediaWiki job queue: https://www.mediawiki.org/wiki/Manual:Job_queue
#
# If --infinite-loop flag is passed, job queue will be processed over and over
# until interrupted, with a pause in between. Useful when this script is run
# simultaneously with a massive editing operation using a bot
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

cd "$WIKIDIR"

if [[ $* == *--infinite-loop* ]]; then
  echo "Process MediaWiki job queue till eternity..."
  echo

  while true; do
    php maintenance/runJobs.php
    sleep 10
  done
else
  echo "Process MediaWiki job queue..."
  echo

  php maintenance/runJobs.php
fi
