#!/bin/bash

# Hitchwiki installation script

echo "-------------------------------------------------"
echo "                    HITCHWIKI"
echo ""
echo " The Hitchhiker's Guide to Hitchhiking the World"
echo "-------------------------------------------------"
echo ""

# Settings
WIKIVERSIONBRANCH="1.24"
WIKIVERSION="1.24.0"
WIKIDIR="public/wiki"

# Test we've got these...
CMDS="curl php git vagrant"
for i in $CMDS
do
  type -P $i &>/dev/null  && continue  || { echo "ERROR: $i command not found. Cannot continue."; exit 1; }
done

# Make sure we're at right directory
SCRIPTDIR="$(dirname "$0")"
cd $SCRIPTDIR/..

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
    curl -O http://releases.wikimedia.org/mediawiki/$WIKIVERSIONBRANCH/mediawiki-$WIKIVERSION.tar.gz;
  fi
  tar xzf mediawiki-$WIKIVERSION.tar.gz -C ./public;
  #rm mediawiki-$WIKIVERSION.tar.gz;
  mv -i public/mediawiki-$WIKIVERSION $WIKIDIR;

  # Config file is stored elsewhere, require it from MW's LocalSettings.php
  WIKISETTINGS=public/wiki/LocalSettings.php
  # Replace file contents with this:
  echo '<?php' >$WIKISETTINGS
  # Appends following lines to file:
  echo '/**' >>$WIKISETTINGS
  echo ' * LOAD HITCHWIKI' >>$WIKISETTINGS
  echo ' *' >>$WIKISETTINGS
  echo ' * When running maintenance scripts inside Vagrant,' >>$WIKISETTINGS
  echo ' * this might have trouble finding config file.' >>$WIKISETTINGS
  echo ' */' >>$WIKISETTINGS
  echo '$HWconfigPath = (file_exists("/var/www/configs/mediawiki.php")) ? "/var/www/configs/mediawiki.php" : "../../configs/mediawiki.php";' >>$WIKISETTINGS
  echo 'require_once($HWconfigPath);' >>$WIKISETTINGS

else
  echo ""
  echo "Skipping downloading MediaWiki: public/wiki folder already exists."
fi

# Install dependencies
echo ""
echo "Installing dependencies..."
php composer.phar install

# Run Vagrant to finalize setup
vagrant up

# Yay!
echo ""
echo "Hitchwiki is now installed!"
echo ""
echo "Vagrant is up. Open http://192.168.33.10/ in your browser."
echo ""
echo "Suspend the virtual machine by calling 'vagrant suspend'."
echo "When you're ready to begin working again, just run 'vagrant up'."
echo ""
echo "Read more from http://github.com/Hitchwiki/hitchwiki"
echo ""
