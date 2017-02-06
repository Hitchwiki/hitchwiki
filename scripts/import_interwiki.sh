#!/bin/bash

#
# Import Hitchwiki pages related to Semantic MediaWiki (forms, templates etc)
#

if [ ! -f Vagrantfile ]; then # an arbirtrary file that appears only once in the whole repository tree
    echo "ERROR: Bad working directory ($(pwd))."
    echo "Scripts have to be run from the root directory of the hitchwiki repository."
    echo "Aborting."
    exit 1
fi

source "scripts/_path_resolve.sh"
source "$SCRIPTDIR/_settings.sh"

# Exit on error
set -e

# Import interwiki table
# https://www.mediawiki.org/wiki/Extension:Interwiki
echo
echo "Importing interwiki table..."
mysql -u$HW__db__username -p$HW__db__password $HW__db__database < "$SCRIPTDIR/configs/interwiki.sql"

echo "All done!"
echo ""
