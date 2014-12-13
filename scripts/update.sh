#!/bin/bash

# Hitchwiki update script


# Update dependencies
echo "Updating dependencies..."
php composer.phar install

# Update Mediawiki
echo "Running update for Mediawiki"
vagrant ssh -c "cd /var/www/public/wiki/ && php maintenance/update.php"
