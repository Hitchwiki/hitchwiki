#!/bin/bash

# Hitchwiki installation script


# Paths
ROOTDIR="/var/www"
CONFDIR="$ROOTDIR/configs"
CONFPATH="$CONFDIR/mediawiki.php"
SCRIPTDIR="$ROOTDIR/scripts"
WIKIDIR="$ROOTDIR/public/wiki"

# Make sure we're at right directory
cd "$ROOTDIR"

# Makes sure we have settings.ini and "Bash ini parser"
source "$SCRIPTDIR/settings.sh"

# Download Composer
# https://www.mediawiki.org/wiki/Composer
if [ ! -f composer.phar ]; then
  echo ""
  echo "Downloading Composer..."
  curl -sS https://getcomposer.org/installer | php
  echo ""
fi

# Clone MW Core
if [ ! -d "$WIKIDIR/.git" ]; then
  echo ""
  echo "Cloning MediaWiki... (this might take a while)"
  cd "$ROOTDIR/public"
  git clone -b $HW__general_mw_branch --single-branch https://gerrit.wikimedia.org/r/p/mediawiki/core.git wiki

  # Use branches for versions, eg. REL1_24
  cd "$WIKIDIR"
  git checkout -b $HW__general_mw_branch origin/$HW__general_mw_branch

  # Get Vector skin
  cd "$WIKIDIR/skins"
  git clone -b $HW__general_mw_branch https://gerrit.wikimedia.org/r/p/mediawiki/skins/Vector.git
fi

# Clone MW skin(s)
#if [ ! -d "$WIKIDIR/skins/Vector" ]; then
#  cd "$WIKIDIR/skins"
#  git clone https://gerrit.wikimedia.org/r/p/mediawiki/skins/Vector.git
#fi

## Download and extract
#if [ ! -f mediawiki-$WIKIVERSION.tar.gz ]; then
#  curl --silent -O http://releases.wikimedia.org/mediawiki/$WIKIVERSIONBRANCH/mediawiki-$WIKIVERSION.tar.gz > /dev/null;
#fi
#tar xzf mediawiki-$WIKIVERSION.tar.gz -C $ROOTDIR/public;
##rm mediawiki-$WIKIVERSION.tar.gz;
#mv -i $ROOTDIR/public/mediawiki-$WIKIVERSION $WIKIDIR;

# Install Hitchwiki dependencies now that we have /wiki directory
echo ""
echo "Installing Hitchwiki dependencies..."
cd "$ROOTDIR"
php composer.phar install --no-progress

# Prepare databases
mysql -u$HW__db__username -p$HW__db__password -e "DROP DATABASE IF EXISTS $HW__db__database"
mysql -u$HW__db__username -p$HW__db__password -e "CREATE DATABASE $HW__db__database CHARACTER SET utf8 COLLATE utf8_general_ci"
#IFS=$'\n' languages=($(echo "SHOW DATABASES;" | mysql -u$username -p$password | grep -E '^hitchwiki_..$' | sed 's/^hitchwiki_//g'))


# Install APC
sudo apt-get -y install php-apc
sudo /etc/init.d/apache2 restart

# Rename config prior to install script so it can pass
#mv LocalSettings.php LocalSettings.php~

# Install MediaWiki dependencies
echo ""
echo "Installing Mediawiki dependencies..."
cd "$WIKIDIR"
cp -f "$ROOTDIR/composer.phar" "$WIKIDIR/composer.phar"
php composer.phar install --no-dev --no-progress

# Install VisualEditor (yeah no composer here...)
if [ ! -d "$WIKIDIR/extensions/VisualEditor" ]; then
  echo ""
  echo "Installing VisualEditor..."
  cd "$WIKIDIR/extensions/"
  git clone -b $HW__general_mw_branch https://gerrit.wikimedia.org/r/p/mediawiki/extensions/VisualEditor.git
  cd VisualEditor
  # Use branches for versions, eg. REL1_24
  git submodule update --init
fi

# Install MediaWiki
echo ""
echo "Installing Mediawiki..."
# Usage: php install.php [--conf|--confpath|--dbname|--dbpass|--dbpassfile|--dbpath|--dbport|--dbprefix|--dbschema|--dbserver|--dbtype|--dbuser|--env-checks|--globals|--help|--installdbpass|--installdbuser|--lang|--memory-limit|--pass|--passfile|--profiler|--quiet|--scriptpath|--server|--wiki] [name] <admin>
cd "$WIKIDIR" && php maintenance/install.php --conf "$CONFPATH" --dbuser $HW__db__username --dbpass $HW__db__password --dbname $HW__db__database --dbtype mysql --pass autobahn --scriptpath /wiki --lang en "$HW__general__sitename" hitchwiki

# Install SemanticMediawiki extensions https://www.semantic-mediawiki.org/
# Install reCaptcha https://github.com/vedmaka/Mediawiki-reCaptcha
# (Less headache to do this here instead of our composer.json)
php composer.phar require --no-progress mediawiki/semantic-media-wiki "~2.0"
php composer.phar require --no-progress mediawiki/semantic-forms "~3.0"
php composer.phar require --no-progress mediawiki/maps "~3.0"
php composer.phar require --no-progress mediawiki/semantic-maps "*"
php composer.phar require --no-progress mediawiki/recaptcha "@dev"
php maintenance/update.php --quick --conf "$CONFPATH"

# Config file is stored elsewhere, require it from MW's LocalSettings.php
cp -f "$SCRIPTDIR/configs/mediawiki_LocalSettings.php" "$WIKIDIR/LocalSettings.php"

# Pre-populate the antispoof (MW extension) table with your wiki's existing usernames
cd "$WIKIDIR"
php extensions/AntiSpoof/maintenance/batchAntiSpoof.php

# Install assets for HWMaps
cd "$WIKIDIR/extensions/HWMap" && bower install --config.interactive=false

# Install assets for HitchwikiVector & HWMap extensions (should be done by composer but fails sometimes)
cd "$WIKIDIR/extensions/HitchwikiVector" && bower install --config.interactive=false

# Install CheckUser
cd "$WIKIDIR/extensions/CheckUser" && php install.php && cd "$WIKIDIR"

cd "$WIKIDIR"

# Create bot account
php maintenance/createAndPromote.php --bureaucrat --sysop --bot --force Hitchbot autobahn

# Create another dummy account
php maintenance/createAndPromote.php Hitchhiker autobahn

# Confirm emails for all created users
mysql -u$HW__db__username -p$HW__db__password $HW__db__database -e "UPDATE user SET user_email = 'hitchwiki@localhost',  user_email_authenticated = '20141218000000' WHERE user_name = 'Hitchwiki'"
mysql -u$HW__db__username -p$HW__db__password $HW__db__database -e "UPDATE user SET user_email = 'hitchbot@localhost',   user_email_authenticated = '20141218000000' WHERE user_name = 'Hitchbot'"
mysql -u$HW__db__username -p$HW__db__password $HW__db__database -e "UPDATE user SET user_email = 'hitchhiker@localhost', user_email_authenticated = '20141218000000' WHERE user_name = 'Hitchhiker'"

# Import Semantic pages
bash "$SCRIPTDIR/import_pages.sh"

# Import interwiki table
mysql -u$HW__db__username -p$HW__db__password $HW__db__database < "$SCRIPTDIR/configs/interwiki.sql"


# Install Parsoid
# https://www.mediawiki.org/wiki/Parsoid/Setup
gpg --keyserver keys.gnupg.net --recv-keys 5C927F7C
gpg -a --export 5C927F7C | sudo apt-key add -
sudo echo "" >> /etc/apt/sources.list
sudo echo "## Parsoid for MediaWiki" >> /etc/apt/sources.list
sudo echo "## https://www.mediawiki.org/wiki/Parsoid/Setup" >> /etc/apt/sources.list
sudo echo "deb [arch=amd64] http://parsoid.wmflabs.org:8080/deb wmf-production main" >> /etc/apt/sources.list
sudo apt-get update && sudo apt-get install parsoid

# Copy our settings for Parsoid (replace hitchwiki.dev domain with domain variable from settings.ini)
localsettingsjs=$(<"$SCRIPTDIR/configs/parsoid_localsettings.js")
sudo mkdir -p /etc/mediawiki/parsoid/
sudo echo "${localsettingsjs//hitchwiki.dev/$HW__general__domain}" > /etc/mediawiki/parsoid/localsettings.js


sudo /bin/cp -f "$SCRIPTDIR/configs/parsoid_initscript" /etc/default/parsoid

# Restart Parsoid to get new settings affect
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
