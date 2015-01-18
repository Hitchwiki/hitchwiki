#!/bin/bash

# Hitchwiki update script

VAGRANT_CONFPATH=/var/www/configs/mediawiki.php
VAGRANT_WIKIDIR=/var/www/public/wiki

# Update dependencies
echo "Updating Hitchwiki dependencies..."
php composer.phar update

echo "Updating MediaWiki dependencies..."
cd public/wiki
git pull
php composer.phar update

cd skins/Vector
git pull
cd ../../

cd extensions/VisualEditor
git pull
git submodule update --init

# Update Mediawiki
echo "Running update script for MediaWiki"
vagrant ssh -c "cd $VAGRANT_WIKIDIR && php maintenance/update.php --quick --conf $VAGRANT_CONFPATH"

echo "Running update script for Semantic MediaWiki"
vagrant ssh -c "cd $VAGRANT_WIKIDIR && php extensions/SemanticMediaWiki/maintenance/SMW_refreshData.php -d 50 -v"

# Update assets for HWMaps
vagrant ssh -c "cd $VAGRANT_WIKIDIR/extensions/HWMap && bower update --config.interactive=false"

# Update assets for HitchwikiVector
vagrant ssh -c "cd $VAGRANT_WIKIDIR/extensions/HitchwikiVector && bower update --config.interactive=false"

# Update locales
vagrant ssh -c "cd $VAGRANT_WIKIDIR && php extensions/LocalisationUpdate/update.php"

# @TODO: ask if to update?
#vagrant ssh -c "bash /var/www/scripts/vagrant_import_pages.sh"

echo ""
echo "All done!"
