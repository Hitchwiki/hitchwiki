#!/bin/bash
set -e
#
# Hitchwiki update script: update MediaWiki, its database, extensions and assets
#
# Usage:
#   "git pull"
#   "bash scripts/update.sh"
#

if [ ! -f Vagrantfile ]; then # an arbirtrary file that appears only once in the whole repository tree
    echo "ERROR: Bad working directory ($(pwd))."
    echo "Scripts have to be run from the root directory of the hitchwiki repository."
    echo "Aborting."
    exit 1
fi
git pull
ansible-playbook ./scripts/update.yml

echo "All done!"
