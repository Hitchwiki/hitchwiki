#!/bin/bash

#
# Set straight file permissions
#

if [ ! -f Vagrantfile ]; then # an arbirtrary file that appears only once in the whole repository tree
    echo "ERROR: Bad working directory ($(pwd))."
    echo "Scripts have to be run from the root directory of the hitchwiki repository."
    echo "Aborting."
    exit 1
fi

source "scripts/path_resolve.sh"

chown -R www-data:www-data .
chmod -R g+rw .

chown -R www-data:www-data public/wiki/images
chmod -R ug+rw public/wiki/images
