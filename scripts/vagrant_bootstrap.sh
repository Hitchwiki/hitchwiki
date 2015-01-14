#!/bin/bash

# Hitchwiki installation script


# Settings
WIKIVERSIONBRANCH="1.24"
WIKIVERSION="1.24.0"

# Paths
ROOTDIR=/var/www
CONFDIR=$ROOTDIR/configs
CONFPATH=$CONFDIR/mediawiki.php
SCRIPTDIR=$ROOTDIR/scripts
WIKIDIR=$ROOTDIR/public/wiki

# Make sure we're at right directory
cd $ROOTDIR

# Makes sure we have settings.ini and "Bash ini parser"
source $SCRIPTDIR/settings.sh

# Make sure public directory exists
if [ ! -d "public" ]; then
  echo ""
  echo "Creating ./public/ directory..."
  mkdir public
fi

# Download Composer
if [ ! -f composer.phar ]; then
  echo ""
  echo "Installing Composer..."
  curl -sS https://getcomposer.org/installer | php
  echo ""
fi

# Install Mediawiki
if [ ! -d "$WIKIDIR" ]; then
  echo ""
  echo "Downloading MediaWiki..."

  # Download and extract
  if [ ! -f mediawiki-$WIKIVERSION.tar.gz ]; then
    curl --silent -O http://releases.wikimedia.org/mediawiki/$WIKIVERSIONBRANCH/mediawiki-$WIKIVERSION.tar.gz > /dev/null;
  fi
  tar xzf mediawiki-$WIKIVERSION.tar.gz -C $ROOTDIR/public;
  #rm mediawiki-$WIKIVERSION.tar.gz;
  mv -i $ROOTDIR/public/mediawiki-$WIKIVERSION $WIKIDIR;

  # Config file is stored elsewhere, require it from MW's LocalSettings.php
  cp $SCRIPTDIR/LocalSettings.php $WIKIDIR/LocalSettings.php

else
  echo ""
  echo "Skipping downloading MediaWiki: public/wiki folder already exists."
fi

# Copy Composer to MediaWiki folder
cp -f $ROOTDIR/composer.phar $WIKIDIR/composer.phar

# Install dependencies
echo ""
echo "Installing dependencies..."
php composer.phar install --no-progress

cd $WIKIDIR

#IFS=$'\n' languages=($(echo "SHOW DATABASES;" | mysql -u$username -p$password | grep -E '^hitchwiki_..$' | sed 's/^hitchwiki_//g'))

# Prepare databases
mysql -u$HW__db__username -p$HW__db__password -e "DROP DATABASE IF EXISTS hitchwiki"
mysql -u$HW__db__username -p$HW__db__password -e "CREATE DATABASE hitchwiki CHARACTER SET utf8 COLLATE utf8_general_ci"


# Rename config so install process can pass
mv LocalSettings.php LocalSettings.php~

# Install APC
sudo apt-get -y install php-apc
sudo /etc/init.d/apache2 restart

# Install MediaWiki
# Usage: php install.php [--conf|--confpath|--dbname|--dbpass|--dbpassfile|--dbpath|--dbport|--dbprefix|--dbschema|--dbserver|--dbtype|--dbuser|--env-checks|--globals|--help|--installdbpass|--installdbuser|--lang|--memory-limit|--pass|--passfile|--profiler|--quiet|--scriptpath|--server|--wiki] [name] <admin>
php maintenance/install.php --conf $CONFPATH --dbuser $HW__db__username --dbpass $HW__db__password --dbname hitchwiki --dbtype mysql --pass autobahn --scriptpath /wiki --lang en "$HW__general__sitename" hitchwiki

# Install SemanticMediawiki extensions
# (Less headache to do this here instead of our composer.json)
php composer.phar require --no-progress mediawiki/semantic-media-wiki "~2.0"
php composer.phar require --no-progress mediawiki/semantic-forms "~3.0"
php composer.phar require --no-progress mediawiki/maps "~3.0"
php composer.phar require --no-progress mediawiki/semantic-maps "*"

php maintenance/update.php --quick --conf $CONFPATH

# Put this back
mv LocalSettings.php~ LocalSettings.php

# Pre-populate the antispoof (MW extension) table with your wiki's existing usernames
php extensions/AntiSpoof/maintenance/batchAntiSpoof.php

# Install assets for HWMaps
vagrant ssh -c "cd $WIKIDIR/extensions/HWMap && bower install --config.interactive=false"

# Install CheckUser
cd $WIKIDIR/extensions/CheckUser && php install.php && cd $WIKIDIR

# Create bot account
php maintenance/createAndPromote.php --bureaucrat --sysop --bot --force Hitchbot autobahn

# Create another dummy account
php maintenance/createAndPromote.php Hitchhiker autobahn

# Confirm emails for all created users
mysql -u$HW__db__username -p$HW__db__password hitchwiki -e "UPDATE user SET user_email = 'hitchwiki@localhost',  user_email_authenticated = '20141218000000' WHERE user_name = 'Hitchwiki'"
mysql -u$HW__db__username -p$HW__db__password hitchwiki -e "UPDATE user SET user_email = 'hitchbot@localhost',   user_email_authenticated = '20141218000000' WHERE user_name = 'Hitchbot'"
mysql -u$HW__db__username -p$HW__db__password hitchwiki -e "UPDATE user SET user_email = 'hitchhiker@localhost', user_email_authenticated = '20141218000000' WHERE user_name = 'Hitchhiker'"

# Import Semantic pages
bash $SCRIPTDIR/vagrant_import_pages.sh

echo ""
echo "Hitchwiki is now installed!"
echo ""
echo "Vagrant is up. Open http://$HW__general__domain/ in your browser."
echo ""
echo "Suspend the virtual machine by calling 'vagrant suspend'."
echo "When you're ready to begin working again, just run 'vagrant up'."
echo ""
echo "Read more from http://github.com/Hitchwiki/hitchwiki"
echo ""

# And we're done!
