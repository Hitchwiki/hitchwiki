#!/bin/bash

#
# Hitchwiki cleaning installation script
#

set -e
cd "$(dirname $0)/.."

if [ ! -f Vagrantfile ]; then # an arbirtrary file that appears only once in the whole repository tree
    echo "ERROR: Bad working directory ($(pwd))."
    echo "Scripts have to be run from the root directory of the hitchwiki repository."
    echo "Aborting."
    exit 1
fi

echo ""
echo "Cleaning up files and folders created by Hitchwiki install..."

# Remove Ansible files
rm -f ./*.retry

# Remove Mediawiki folder
rm -fr ./public/wiki

# Other folders or files created by installation
rm -f ./composer.lock
rm -fr ./public/composer

# Remove log files
rm -f ./*-cloudimg-console.log
rm -f ./scripts/*-cloudimg-console.log

echo "Cleaning done!"
