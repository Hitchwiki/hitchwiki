#!/bin/bash

#
# Shorthand to reinstall Vagrant system
#
# TODO: similar script for non-Vagrant setup
#

if [ ! -f Vagrantfile ]; then # an arbirtrary file that appears only once in the whole repository tree
    echo "ERROR: Bad working directory ($(pwd))."
    echo "Scripts have to be run from the root directory of the hitchwiki repository."
    echo "Aborting."
    exit 1
fi

source "scripts/_path_resolve.sh"

set -e
clear

echo
echo "Removing previous files and Vagrant machine..."

rm -fr "$ROOTDIR/composer.lock"
rm -fr "$WIKIDIR"
vagrant destroy --force # Do not ask for confirmation before destroying.
bash "$SCRIPTDIR/vagrant/install.sh"
