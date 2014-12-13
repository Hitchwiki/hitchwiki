#!/bin/bash

# Hitchwiki update script


# Update dependencies
echo "Updating dependencies..."
php composer.phar update

# Update Mediawiki
echo "Running update script for MediaWiki"
vagrant ssh -c "cd /var/www/public/wiki/ && php maintenance/update.php"

echo "Running update script for Semantic MediaWiki"
vagrant ssh -c "cd /var/www/public/wiki/ && php extensions/SemanticMediaWiki/maintenance/SMW_refreshData.php -d 50 -v"
