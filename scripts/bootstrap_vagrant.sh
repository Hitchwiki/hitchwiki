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


# Fixes possible "warning: Setting locale failed." errors
export LC_ALL="en_US.UTF-8"
export LANGUAGE="en_US.UTF-8"


# Vagrant SCOTCH BOX (https://box.scotch.io/) has git 1.9
# and we want 2+ for shallow submodules
echo "\n"
echo "Upgrade git to v2"
sudo add-apt-repository -y ppa:git-core/ppa
sudo apt-get -qq update
sudo apt-get -y install git
git --version
echo "\n"
echo "-------------------------------------------------------------------------"


echo "\n"
echo "Install PEAR mail, Net_SMTP, Auth_SASL and mail_mime..."
sudo pear install mail
sudo pear install Net_SMTP
sudo pear install Auth_SASL
sudo pear install mail_mime
echo "\n"
echo "-------------------------------------------------------------------------"


echo "\n"
echo "Upgrade Composer to latest version..."
composer self-update
echo "\n"
echo "-------------------------------------------------------------------------"


echo "\n"
echo "Download MediaWiki using Composer..."
cd "$ROOTDIR"
composer install --no-autoloader --no-dev --no-progress --no-interaction
echo "\n"
echo "-------------------------------------------------------------------------"


echo "\n"
echo "Create cache directories..."
mkdir -p "$WIKIDIR/cache"
mkdir -p "$WIKIDIR/images/cache"
echo "\n"
echo "-------------------------------------------------------------------------"


echo "\n"
echo "Ensure correct permissions for cache folders..."
chown www-data:www-data $WIKIDIR/cache
chown www-data:www-data $WIKIDIR/images/cache
echo "\n"
echo "-------------------------------------------------------------------------"


echo "\n"
echo "Download basic MediaWiki extensions using Composer..."
cd "$WIKIDIR"
cp "$CONFDIR/composer.local.json" .
composer update --no-dev --no-progress --no-interaction
echo "\n"
echo "-------------------------------------------------------------------------"


# Run some post-install scripts for a few extensions
# These are not run automatically so we'll just manually invoke them.
# https://github.com/composer/composer/issues/1193
cd "$WIKIDIR"
echo "\n"
echo "Run post-install-cmd for HWMap extension..."
composer run-script post-install-cmd -d ./extensions/HWMap
echo "\n"
echo "Run post-install-cmd for HitchwikiVector extension..."
composer run-script post-install-cmd -d ./extensions/HitchwikiVector
echo "\n"
echo "-------------------------------------------------------------------------"

# Install VisualEditor
# Since it requires submodules, we don't install this using composer
# https://www.mediawiki.org/wiki/Extension:VisualEditor
if [[ ! $* == *--no-visualeditor* ]]; then # optional command line flag that excludes VisualEditor/Parsoid from installation
  echo "\n"
  echo "Install VisualEditor extension..."
  cd "$WIKIDIR/extensions"
  git clone \
      --branch $HW__general__mw_branch \
      --single-branch \
      --depth=1 \
      --recurse-submodules \
      --quiet \
      https://github.com/wikimedia/mediawiki-extensions-VisualEditor.git \
      VisualEditor;
else
  echo "\n"
  echo "Skipped Installing VisualEditor extension."
fi
echo "\n"
echo "-------------------------------------------------------------------------"


# Stop Maps extension from setting up a {{#coordinates}} parser function hook
# that conflicts with GeoData extensions's {{#coordinates}} parser function hook
#
# We are using GeoData's function in templates to index articles with spatial info
#
# TODO: any solution that is cleaner than this temporary dirty hack..
echo "\n"
echo "Stop Maps extension from setting up a {{#coordinates}} parser function hook..."
sed -i -e '111i\ \ /*' -e '116i\ \ */' "$WIKIDIR/extensions/Maps/Maps.php" # wrap damaging lines of code as a /* comment */
sed -i -e '112i\ \ // This code block has been commented out by Hitchwiki install script. See scripts/bootstrap_vagrant.sh for details\n' "$WIKIDIR/extensions/Maps/Maps.php"
echo "\n"
echo "-------------------------------------------------------------------------"

# Prepare databases
echo "Prepare databases..."
mysql -u$HW__db__username -p$HW__db__password -e "DROP DATABASE IF EXISTS $HW__db__database"
mysql -u$HW__db__username -p$HW__db__password -e "CREATE DATABASE $HW__db__database CHARACTER SET utf8 COLLATE utf8_general_ci"
#IFS=$'\n' languages=($(echo "SHOW DATABASES;" | mysql -u$username -p$password | grep -E '^hitchwiki_..$' | sed 's/^hitchwiki_//g'))
echo "\n"
echo "-------------------------------------------------------------------------"


# Install APC
# TODO: https://www.digitalocean.com/community/questions/how-to-install-alternative-php-cache-apc-on-ubuntu-14-04
#echo "\n"
#echo "Install APC..."
#sudo apt-get -y install php-apc
#echo "\n"
#echo "Restart Apache..."
#sudo /etc/init.d/apache2 restart


# Setup MediaWiki
echo "\n"
echo "Running Mediawiki setup script..."
# Usage: php install.php [--conf|--confpath|--dbname|--dbpass|--dbpassfile|--dbpath|--dbport|--dbprefix|--dbschema|--dbserver|--dbtype|--dbuser|--env-checks|--globals|--help|--installdbpass|--installdbuser|--lang|--memory-limit|--pass|--passfile|--profiler|--quiet|--scriptpath|--server|--wiki] [name] <admin>
cd "$WIKIDIR"
# Runs Mediawiki install script:
# - sets up wiki in one language ("en")
# - creates one admin user "hitchwiki" with password "authobahn"
php maintenance/install.php --conf "$CONFPATH" \
                            --dbuser $HW__db__username \
                            --dbpass $HW__db__password \
                            --dbname $HW__db__database \
                            --dbtype mysql \
                            --pass autobahn \
                            --scriptpath /$WIKIFOLDER \
                            --lang en \
                            "$HW__general__sitename" \
                            hitchwiki;
echo "\n"
echo "-------------------------------------------------------------------------"


# Config file is stored elsewhere, require it from MW's LocalSettings.php
echo "\n"
echo "Point Mediawiki configuration to Hitchwiki configuration file..."
cp -f "$SCRIPTDIR/configs/mediawiki_LocalSettings.php" "$WIKIDIR/LocalSettings.php"
echo "\n"
echo "-------------------------------------------------------------------------"


echo "\n"
echo "Setup database for several extensions (SemanticMediaWiki, AntiSpoof etc)..."
# Mediawiki config file has a check for `SemanticMediaWikiEnabled` file:
# basically SMW extensions are not included in MediaWiki before this
# file exists, because it would cause errors when running
# `maintenance/install.php`.
touch "$WIKIDIR/extensions/SemanticMediaWikiEnabled"
cd "$WIKIDIR"
php maintenance/update.php --quick --conf "$CONFPATH"
echo "\n"
echo "-------------------------------------------------------------------------"


echo "\n"
echo "Pre-populate the AntiSpoof extension's table..."
cd "$WIKIDIR"
php extensions/AntiSpoof/maintenance/batchAntiSpoof.php
echo "\n"
echo "-------------------------------------------------------------------------"


# Setup CheckUser
echo "\n"
echo "Setup CheckUser..."
cd "$WIKIDIR/extensions/CheckUser" && php install.php && cd "$WIKIDIR"
echo "\n"
echo "-------------------------------------------------------------------------"


# Create bot users
echo "\n"
echo "Create users"
cd "$ROOTDIR"
bash "$SCRIPTDIR/create_users.sh"
echo "\n"
echo "-------------------------------------------------------------------------"


# Import Semantic pages, main navigation etc
echo "\n"
echo "Import Semantic templates and other MediaWiki special pages..."
cd "$ROOTDIR"
bash "$SCRIPTDIR/import_pages.sh"
echo "\n"
echo "-------------------------------------------------------------------------"


# Import interwiki table
# https://www.mediawiki.org/wiki/Extension:Interwiki
echo "\n"
echo "Import interwiki table..."
mysql -u$HW__db__username -p$HW__db__password $HW__db__database < "$SCRIPTDIR/configs/interwiki.sql"
echo "\n"
echo "-------------------------------------------------------------------------"


# Install Parsoid
# Parsoid is a Node application required by VisualEditor extension
# https://www.mediawiki.org/wiki/Parsoid/Setup
if [[ ! $* == *--no-visualeditor* ]]; then # optional command line flag that excludes VisualEditor/Parsoid from installation
  echo "\n"
  echo "Call Parsoid install script..."
  bash "$SCRIPTDIR/install_parsoid.sh"
else
  echo "\n"
  echo "Skipped calling Parsoid install script."
fi
echo "\n"
echo "-------------------------------------------------------------------------"



# And we're done!

echo "\n"
echo "\n"
echo "-------------------------------------------------------------------------"
echo "\n"
echo "Hitchwiki is now installed!"
echo "\n"
echo "Vagrant is up. Open http://$HW__general__domain/ in your browser."
echo "\n"
if [[ ! $* == *--no-visualeditor* ]]; then # optional command line flag that excludes VisualEditor/Parsoid from installation
  echo "Parsoid is running. Open http://$HW__general__domain:8142 in your browser."
  echo "\n"
fi
echo "Suspend the virtual machine by calling 'vagrant suspend'."
echo "When you're ready to begin working again, just run 'vagrant up'."
echo "\n"
echo "Read more from http://github.com/Hitchwiki/hitchwiki"
echo "\n"
