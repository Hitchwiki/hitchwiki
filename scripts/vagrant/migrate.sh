#!/bin/bash

#
# Shorthand to run scripts/migrate.sh inside the Vagrant box
#
# On not Vagrant-based setups (eg. production), directly invoke scripts/migrate.sh instead
#
# [!] Existing database will be dropped, so use with caution
#

if [ ! -f Vagrantfile ]; then # an arbirtrary file that appears only once in the whole repository tree
    echo "ERROR: Bad working directory ($(pwd))."
    echo "Scripts have to be run from the root directory of the hitchwiki repository."
    echo "Aborting."
    exit 1
fi

source "scripts/_path_resolve.sh"

# Run migrate script inside Vagrant
vagrant ssh -c "cd \"$VAGRANT_ROOTDIR\" && bash \"$VAGRANT_SCRIPTDIR/migrate.sh\""
