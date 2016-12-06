#!/bin/bash

# Hitchwiki installation script


# Paths
ROOTDIR="/var/www"
CONFDIR="$ROOTDIR/configs"
CONFPATH="$CONFDIR/mediawiki.php"
SCRIPTDIR="$ROOTDIR/scripts"
WIKIFOLDER="wiki"
WIKIDIR="$ROOTDIR/public/$WIKIFOLDER"

# Make sure we're at right directory
cd "$ROOTDIR"

# Makes sure we have settings.ini and "Bash ini parser"
source "$SCRIPTDIR/_settings.sh"


echo ""
echo "Upgrade Composer"
composer self-update


echo ""
echo "Download MediaWiki using Composer..."
cd "$ROOTDIR"
composer install --no-autoloader --no-dev --no-progress --no-interaction


echo ""
echo "Create cache directories..."
mkdir -p "$WIKIDIR/cache"
mkdir -p "$WIKIDIR/images/cache"


echo ""
echo "Ensure correct permissions for cache folders..."
chown www-data:www-data $WIKIDIR/cache
chown www-data:www-data $WIKIDIR/images/cache


echo ""
echo "Download basic MediaWiki extensions using Composer..."
cd "$WIKIDIR"
cp "$CONFDIR/composer.local.json" .
composer update --no-dev --no-progress --no-interaction


# Prepare databases
echo "Prepare databases..."
mysql -u$HW__db__username -p$HW__db__password -e "DROP DATABASE IF EXISTS $HW__db__database"
mysql -u$HW__db__username -p$HW__db__password -e "CREATE DATABASE $HW__db__database CHARACTER SET utf8 COLLATE utf8_general_ci"
#IFS=$'\n' languages=($(echo "SHOW DATABASES;" | mysql -u$username -p$password | grep -E '^hitchwiki_..$' | sed 's/^hitchwiki_//g'))


# Install APC
# TODO: https://www.digitalocean.com/community/questions/how-to-install-alternative-php-cache-apc-on-ubuntu-14-04
#echo ""
#echo "Install APC..."
#sudo apt-get -y install php-apc
#echo ""
#echo "Restart Apache..."
#sudo /etc/init.d/apache2 restart


# Install VisualEditor
# (yeah no composer here...)
#if [ ! -d "$WIKIDIR/extensions/VisualEditor" ]; then
#  echo ""
#  echo "Installing VisualEditor..."
#  cd "$WIKIDIR/extensions/"
#  git clone --depth=1 --single-branch -b $HW__general__mw_branch https://gerrit.wikimedia.org/r/p/mediawiki/extensions/VisualEditor.git
#  cd VisualEditor
#  echo "Get Visual editor git submodules..."
#  git submodule update --init
#fi


# Setup MediaWiki
echo ""
echo "Running Mediawiki setup script..."
# Usage: php install.php [--conf|--confpath|--dbname|--dbpass|--dbpassfile|--dbpath|--dbport|--dbprefix|--dbschema|--dbserver|--dbtype|--dbuser|--env-checks|--globals|--help|--installdbpass|--installdbuser|--lang|--memory-limit|--pass|--passfile|--profiler|--quiet|--scriptpath|--server|--wiki] [name] <admin>
cd "$WIKIDIR"
php maintenance/install.php --conf "$CONFPATH" \
                            --dbuser $HW__db__username \
                            --dbpass $HW__db__password \
                            --dbname $HW__db__database \
                            --dbtype mysql \
                            --pass autobahn \ # admin pass
                            --scriptpath /$WIKIFOLDER \
                            --lang en \
                            "$HW__general__sitename" \ # site name
                            hitchwiki; # admin name

# Config file is stored elsewhere, require it from MW's LocalSettings.php
echo ""
echo "Point Mediawiki configuration to Hitchwiki configuration file..."
cp -f "$SCRIPTDIR/configs/mediawiki_LocalSettings.php" "$WIKIDIR/LocalSettings.php"


echo ""
echo "Setup SemanticMediaWiki"
touch "$WIKIDIR/extensions/SemanticMediaWikiEnabled"
cd "$WIKIDIR"
php maintenance/update.php --quick --conf "$CONFPATH"


# Pre-populate the antispoof (MW extension) table with your wiki's existing usernames
echo ""
echo "Pre-populate the antispoof (MW extension) table with your wiki's existing usernames..."
cd "$WIKIDIR"
php extensions/AntiSpoof/maintenance/batchAntiSpoof.php


# Run post-install scripts for several of our own extensions
# These are not run automatically so we'll just manually invoke them.
# https://github.com/composer/composer/issues/1193
cd "$WIKIDIR"
echo ""
echo "Run post install script for HWMap extension..."
composer run-script post-install-cmd -d ./extensions/HWMap/
echo ""
echo "Run post install script for HitchwikiVector extension..."
composer run-script post-install-cmd -d ./extensions/HitchwikiVector/


# Install CheckUser
echo ""
echo "Setup CheckUser..."
cd "$WIKIDIR/extensions/CheckUser" && php install.php && cd "$WIKIDIR"

cd "$WIKIDIR"


# Create bot account
echo ""
echo "Create bot account..."
php maintenance/createAndPromote.php --bureaucrat --sysop --bot --force Hitchbot autobahn


# Create another dummy account
echo "Create another dummy account..."
php maintenance/createAndPromote.php Hitchhiker autobahn


# Import Semantic pages
echo ""
echo "Import Semantic pages..."
cd "$ROOTDIR"
bash "$SCRIPTDIR/import_pages.sh"


# Import interwiki table
echo ""
echo "Import interwiki table..."
mysql -u$HW__db__username -p$HW__db__password $HW__db__database < "$SCRIPTDIR/configs/interwiki.sql"


# Install Parsoid
# https://www.mediawiki.org/wiki/Parsoid/Setup
if [[ ! $* == *--no-visualeditor* ]]; then # optional command line flag that excludes VisualEditor/Parsoid from installation
  echo ""
  echo "Install Parsoid..."
  sudo apt-key advanced --keyserver pgp.mit.edu --recv-keys 90E9F83F22250DD7
  sudo apt-add-repository "deb https://releases.wikimedia.org/debian jessie-mediawiki main"
  sudo apt-get install apt-transport-https
  sudo apt-get update && sudo apt-get install parsoid

  # Copy our settings for Parsoid (replace hitchwiki.dev domain with domain variable from settings.ini)
  echo ""
  echo "Setup Parsoid configs..."
  localsettingsjs=$(<"$SCRIPTDIR/configs/parsoid_localsettings.js")
  sudo mkdir -p /etc/mediawiki/parsoid/
  sudo echo "${localsettingsjs//hitchwiki.dev/$HW__general__domain}" > /etc/mediawiki/parsoid/localsettings.js

  sudo /bin/cp -f "$SCRIPTDIR/configs/parsoid_initscript" /etc/default/parsoid
fi

# Restart Parsoid to get new settings affect
echo ""
echo "Restart Parsoid to get new settings affect..."
sudo service parsoid restart


# And we're done!

echo ""
echo ""
echo "---------------------------------------------------------------------"
echo ""
echo "Hitchwiki is now installed!"
echo ""
echo "Vagrant is up. Open http://$HW__general__domain/ in your browser."
echo ""
echo "Parsoid is running. Open http://$HW__general__domain:8142 in your browser."
echo ""
echo "Suspend the virtual machine by calling 'vagrant suspend'."
echo "When you're ready to begin working again, just run 'vagrant up'."
echo ""
echo "Read more from http://github.com/Hitchwiki/hitchwiki"
echo ""
