#!/bin/bash

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
source "scripts/path_resolve.sh"
source "scripts/settings.sh"

echo ""

echo "Update Hitchwiki dependencies..."
php composer.phar update
echo ""

echo "Update MediaWiki dependencies..."
cd "$WIKIDIR"
git checkout -b $HW__general_mw_branch origin/$HW__general_mw_branch
git pull
php composer.phar update
echo ""

echo "Update Vector skin..."
cd "$WIKIDIR/skins/Vector"
git checkout -b $HW__general_mw_branch origin/$HW__general_mw_branch
git pull
echo ""

echo "Update VisualEditor..."
cd "$WIKIDIR/extensions/VisualEditor"
git checkout -b $HW__general_mw_branch origin/$HW__general_mw_branch
git pull
git submodule update --init
echo ""

echo "Run update script for MediaWiki..."
cd "$WIKIDIR"
php maintenance/update.php --doshared --quick --conf "$MWCONFFILE"
echo ""

echo "Run update script for Semantic MediaWiki..."
cd "$WIKIDIR"
php extensions/SemanticMediaWiki/maintenance/SMW_refreshData.php -d 50 -v
echo ""

echo "Update assets for HWMap..."
cd "$WIKIDIR/extensions/HWMap"
bower update --config.interactive=false
echo ""

echo "Update assets for HitchwikiVector..."
cd "$WIKIDIR/extensions/HitchwikiVector"
bower update --config.interactive=false
echo ""

echo "Fetch latest localisation files..." # Update locales
cd "$WIKIDIR"
php extensions/LocalisationUpdate/update.php
echo ""

# @TODO: ask if to import?
# cd "$SCRIPTDIR"
# bash ./scripts/import_pages.sh
# echo ""

echo "All done!"
