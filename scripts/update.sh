#!/bin/bash

# Hitchwiki update script

VAGRANT_CONFPATH=/var/www/configs/mediawiki.php
VAGRANT_WIKIDIR=/var/www/public/wiki/

# Update dependencies
echo "Updating dependencies..."
php composer.phar update

# Update Mediawiki
echo "Running update script for MediaWiki"
vagrant ssh -c "cd $VAGRANT_WIKIDIR && php maintenance/update.php --quick --conf $VAGRANT_CONFPATH"

echo "Running update script for Semantic MediaWiki"
vagrant ssh -c "cd $VAGRANT_WIKIDIR && php extensions/SemanticMediaWiki/maintenance/SMW_refreshData.php -d 50 -v"

# @TODO: ask if to update?
#vagrant ssh -c "bash /var/www/scripts/vagrant_import_pages.sh"

echo ""
echo "All done!"
