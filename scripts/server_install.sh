#!/bin/bash

#
# Hitchwiki installation script
#
# To set up Hitchwiki inside a Vagrant box, use scripts/vagrant/install.sh instead
#

if [ ! -f Vagrantfile ]; then # an arbirtrary file that appears only once in the whole repository tree
    echo "ERROR: Bad working directory ($(pwd))."
    echo "Scripts have to be run from the root directory of the hitchwiki repository."
    echo "Aborting."
    exit 1
fi

source "scripts/_path_resolve.sh"

# Makes sure we have settings.ini and "Bash ini parser"
source "$SCRIPTDIR/_settings.sh"

# Make sure we're at right directory
cd "$ROOTDIR"

# Fixes possible "warning: Setting locale failed." errors
export LC_ALL="en_US.UTF-8"
export LANGUAGE="en_US.UTF-8"


# Vagrant SCOTCH BOX (https://box.scotch.io/) has git 1.9
# and we want 2+ for shallow submodules
echo
echo "Upgrade git to v2"
sudo add-apt-repository -y ppa:git-core/ppa
sudo apt-get -qq update
sudo apt-get -y install git
git --version
echo
echo "-------------------------------------------------------------------------"


echo
echo "Install PEAR mail, Net_SMTP, Auth_SASL and mail_mime..."
sudo pear install mail
sudo pear install Net_SMTP
sudo pear install Auth_SASL
sudo pear install mail_mime
echo
echo "-------------------------------------------------------------------------"


echo
echo "Upgrade Composer to latest version..."
composer self-update
echo
echo "-------------------------------------------------------------------------"


echo
echo "Download MediaWiki using Composer..."
cd "$ROOTDIR"
composer install --no-autoloader --no-dev --no-progress --no-interaction
echo
echo "-------------------------------------------------------------------------"


echo
echo "Create cache directories..."
mkdir -p "$WIKIDIR/cache"
mkdir -p "$WIKIDIR/images/cache"
echo
echo "-------------------------------------------------------------------------"


echo
echo "Ensure correct permissions for cache folders..."
chown www-data:www-data $WIKIDIR/cache
chown www-data:www-data $WIKIDIR/images/cache
echo
echo "-------------------------------------------------------------------------"


echo
echo "Download basic MediaWiki extensions using Composer..."
cd "$WIKIDIR"
cp "$CONFDIR/composer.local.json" .
composer update --no-dev --no-progress --no-interaction
echo
echo "-------------------------------------------------------------------------"


# Run some post-install scripts for a few extensions
# These are not run automatically so we'll just manually invoke them.
# https://github.com/composer/composer/issues/1193
cd "$WIKIDIR"
echo
echo "Run post-install-cmd for HWMap extension..."
composer run-script post-install-cmd -d ./extensions/HWMap
echo
echo "Run post-install-cmd for HitchwikiVector extension..."
composer run-script post-install-cmd -d ./extensions/HitchwikiVector
echo
echo "Run post-install-cmd for HWRatings extension..."
composer run-script post-install-cmd -d ./extensions/HWRatings
echo
echo "Run post-install-cmd for HWLocationInput extension..."
composer run-script post-install-cmd -d ./extensions/HWLocationInput
echo
echo "-------------------------------------------------------------------------"

# Install VisualEditor
# Since it requires submodules, we don't install this using composer
# https://www.mediawiki.org/wiki/Extension:VisualEditor
if [[ ! $* == *--no-visualeditor* ]]; then # optional command line flag that excludes VisualEditor/Parsoid from installation
  echo
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
  echo
  echo "Skipped Installing VisualEditor extension."
fi
echo
echo "-------------------------------------------------------------------------"


# Stop Maps extension from setting up a {{#coordinates}} parser function hook
# that conflicts with GeoData extensions's {{#coordinates}} parser function hook
#
# We are using GeoData's function in templates to index articles with spatial info
#
# TODO: any solution that is cleaner than this temporary dirty hack..
echo
echo "Stop Maps extension from setting up a {{#coordinates}} parser function hook..."
sed -i -e '111i\ \ /*' -e '116i\ \ */' "$WIKIDIR/extensions/Maps/Maps.php" # wrap damaging lines of code as a /* comment */
sed -i -e '112i\ \ // This code block has been commented out by Hitchwiki install script. See scripts/server_install.sh for details\n' "$WIKIDIR/extensions/Maps/Maps.php"
echo
echo "-------------------------------------------------------------------------"

# Prepare databases
echo
echo "Prepare databases..."
mysql -u$HW__db__username -p$HW__db__password -e "DROP DATABASE IF EXISTS $HW__db__database"
mysql -u$HW__db__username -p$HW__db__password -e "CREATE DATABASE $HW__db__database CHARACTER SET utf8 COLLATE utf8_general_ci"
#IFS=$'\n' languages=($(echo "SHOW DATABASES;" | mysql -u$username -p$password | grep -E '^hitchwiki_..$' | sed 's/^hitchwiki_//g'))
echo
echo "-------------------------------------------------------------------------"


# Install APC
# TODO: https://www.digitalocean.com/community/questions/how-to-install-alternative-php-cache-apc-on-ubuntu-14-04
#echo
#echo "Install APC..."
#sudo apt-get -y install php-apc
#echo
#echo "Restart Apache..."
#sudo /etc/init.d/apache2 restart


# Setup MediaWiki
echo
echo "Running Mediawiki setup script..."
# Usage: php install.php [--conf|--confpath|--dbname|--dbpass|--dbpassfile|--dbpath|--dbport|--dbprefix|--dbschema|--dbserver|--dbtype|--dbuser|--env-checks|--globals|--help|--installdbpass|--installdbuser|--lang|--memory-limit|--pass|--passfile|--profiler|--quiet|--scriptpath|--server|--wiki] [name] <admin>
cd "$WIKIDIR"
# Runs Mediawiki install script:
# - sets up wiki in one language ("en")
# - creates one admin user "hitchwiki" with password "authobahn"
php maintenance/install.php --conf "$MWCONFFILE" \
                            --dbuser $HW__db__username \
                            --dbpass $HW__db__password \
                            --dbname $HW__db__database \
                            --dbtype mysql \
                            --pass autobahn \
                            --scriptpath /$WIKIFOLDER \
                            --lang en \
                            "$HW__general__sitename" \
                            hitchwiki;
echo
echo "-------------------------------------------------------------------------"


# Config file is stored elsewhere, require it from MW's LocalSettings.php
echo
echo "Point Mediawiki configuration to Hitchwiki configuration file..."
cp -f "$SCRIPTDIR/configs/mediawiki_LocalSettings.php" "$WIKIDIR/LocalSettings.php"
echo
echo "-------------------------------------------------------------------------"


echo
echo "Setup database for several extensions (SemanticMediaWiki, AntiSpoof etc)..."
# Mediawiki config file has a check for `SemanticMediaWikiEnabled` file:
# basically SMW extensions are not included in MediaWiki before this
# file exists, because it would cause errors when running
# `maintenance/install.php`.
touch "$WIKIDIR/extensions/SemanticMediaWikiEnabled"
cd "$WIKIDIR"
php maintenance/update.php --quick --conf "$MWCONFFILE"
echo
echo "-------------------------------------------------------------------------"


echo
echo "Pre-populate the AntiSpoof extension's table..."
cd "$WIKIDIR"
php extensions/AntiSpoof/maintenance/batchAntiSpoof.php
echo
echo "-------------------------------------------------------------------------"


# Create bot users
echo
echo "Create users"
cd "$ROOTDIR"
bash "$SCRIPTDIR/create_users.sh"
echo
echo "-------------------------------------------------------------------------"


# Import Semantic pages, main navigation etc
echo
echo "Import Semantic templates and other MediaWiki special pages..."
cd "$ROOTDIR"
bash "$SCRIPTDIR/import_pages.sh"
echo
echo "-------------------------------------------------------------------------"


# Import interwiki table
# https://www.mediawiki.org/wiki/Extension:Interwiki
echo
echo "Import interwiki table..."
mysql -u$HW__db__username -p$HW__db__password $HW__db__database < "$SCRIPTDIR/configs/interwiki.sql"
echo
echo "-------------------------------------------------------------------------"


# Install Parsoid
# Parsoid is a Node application required by VisualEditor extension
# https://www.mediawiki.org/wiki/Parsoid/Setup
if [[ ! $* == *--no-visualeditor* ]]; then # optional command line flag that excludes VisualEditor/Parsoid from installation
  echo
  echo "Call Parsoid install script..."
  cd "$ROOTDIR"
  bash "$SCRIPTDIR/install_parsoid.sh"
else
  echo
  echo "Skipped calling Parsoid install script."
fi
echo
echo "-------------------------------------------------------------------------"



# And we're done!

echo
echo
echo "-------------------------------------------------------------------------"
echo
echo "Hitchwiki is now installed!"
echo
echo "Vagrant is up. Open http://$HW__general__domain/ in your browser."
echo
if [[ ! $* == *--no-visualeditor* ]]; then # optional command line flag that excludes VisualEditor/Parsoid from installation
  echo "Parsoid is running. Open http://$HW__general__domain:8142 in your browser."
  echo
fi
echo "Suspend the virtual machine by calling 'vagrant suspend'."
echo "When you're ready to begin working again, just run 'vagrant up'."
echo
echo "Read more from http://github.com/Hitchwiki/hitchwiki"
echo
