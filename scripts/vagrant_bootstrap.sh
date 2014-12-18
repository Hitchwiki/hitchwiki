#!/bin/bash

CONFPATH=/var/www/configs/mediawiki.php
SCRIPTDIR=/var/www/scripts
WIKIDIR=/var/www/public/wiki
DUMPSDIR=/var/www/dumps

source $SCRIPTDIR/settings.sh

cd $WIKIDIR

#IFS=$'\n' languages=($(echo "SHOW DATABASES;" | mysql -u$username -p$password | grep -E '^hitchwiki_..$' | sed 's/^hitchwiki_//g'))

# Prepare databases
mysql -u$HW__db__username -p$HW__db__password < $DUMPSDIR/hitchwiki_db.sql

# Import dev mediawiki SQL dump
#zcat $DUMPSDIR/hitchwiki_dev.sql.gz | mysql -u$HW__db__username -p$HW__db__password hitchwiki

# Rename config so install process can pass
mv LocalSettings.php LocalSettings.php~

# Install MediaWiki
# Usage: php install.php [--conf|--confpath|--dbname|--dbpass|--dbpassfile|--dbpath|--dbport|--dbprefix|--dbschema|--dbserver|--dbtype|--dbuser|--env-checks|--globals|--help|--installdbpass|--installdbuser|--lang|--memory-limit|--pass|--passfile|--profiler|--quiet|--scriptpath|--server|--wiki] [name] <admin>
php maintenance/install.php --conf $CONFPATH --dbuser $HW__db__username --dbpass $HW__db__password --dbname hitchwiki --dbtype mysql --pass autobahn --scriptpath /wiki --lang en "$HW__general__sitename" hitchwiki

# Download Composer
if [ ! -f composer.phar ]; then
  curl -sS https://getcomposer.org/installer | php
fi

# Install SemanticMediawiki extensions
# (Less headache to do this here instead of our composer.json)
php composer.phar require mediawiki/semantic-media-wiki "~2.0"
php composer.phar require mediawiki/semantic-forms "~3.0"
php composer.phar require mediawiki/maps "*"
php composer.phar require mediawiki/semantic-maps "~3.1"

php maintenance/update.php --conf $CONFPATH --quick

# Put this back
mv LocalSettings.php~ LocalSettings.php

# Pre-populate the antispoof (MW extension) table with your wiki's existing usernames
php extensions/AntiSpoof/maintenance/batchAntiSpoof.php

# Install CheckUser
cd $WIKIDIR/extensions/CheckUser && php install.php

# Turn Hitchwiki admin account into a bot
cd $WIKIDIR && php maintenance/createAndPromote.php --bureaucrat --sysop --bot --force Hitchwiki

# Import pages
bash $SCRIPTDIR/vagrant_import_pages.sh

# And we're done!
