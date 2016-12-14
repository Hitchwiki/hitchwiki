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

source "scripts/_path_resolve.sh"

chown -R www-data:www-data "$ROOTDIR"
chmod -R g+rw "$ROOTDIR"

chown -R www-data:www-data "$WIKIDIR/images"
chmod -R ug+rw "$WIKIDIR/images"

chown -R www-data:www-data "$WIKIDIR/cache"
chmod -R ug+rw "$WIKIDIR/cache"
