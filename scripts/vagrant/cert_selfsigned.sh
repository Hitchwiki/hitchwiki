#!/bin/bash

#
# Shorthand to run scripts/cert_selfsigned.sh inside the Vagrant box
#
# On not Vagrant-based setups (eg. production), directly invoke scripts/cert_selfsigned.sh instead
#

if [ ! -f Vagrantfile ]; then # an arbirtrary file that appears only once in the whole repository tree
    echo "ERROR: Bad working directory ($(pwd))."
    echo "Scripts have to be run from the root directory of the hitchwiki repository."
    echo "Aborting."
    exit 1
fi

source "scripts/_path_resolve.sh"

# Scripts rely on working directory being the root directory of this git repository
if [ -z "${1+x}" ]; then
  vagrant ssh -c "cd \"$VAGRANT_ROOTDIR\" && bash \"$VAGRANT_SCRIPTDIR/cert_selfsigned.sh\""
else
  vagrant ssh -c "cd \"$VAGRANT_ROOTDIR\" && bash \"$VAGRANT_SCRIPTDIR/cert_selfsigned.sh\" \"$1\""
fi
