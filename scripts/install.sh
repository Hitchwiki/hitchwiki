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

# Make sure public directory exists
if [ ! -d "public" ]; then
  echo "Creating ./public/ directory..."
  mkdir public
fi

# Download Composer
if [ ! -f composer.phar ]; then
  echo "Installing Composer..."
  curl -sS https://getcomposer.org/installer | php
  echo ""
fi

# Install Scotchbox
#echo "Scotch-box (http://box.scotch.io/) is a LAMP Vagrantbox useful for developing."
#echo "You could also choose to run your own AMP setup but Vagrant method is recommended."
#while true; do
#  read -p "Install Scotchbox? " yn
#  case $yn in
#    [Yy]* )
#      SCOTCHBOX=true
#      git clone https://github.com/scotch-io/scotch-box.git scotch-box && mv scotch-box/Vagrantfile ./ && rm -fr scotch-box;
#      break;;
#    [Nn]* )
#      SCOTCHBOX=false
#      exit;;
#    * ) echo "(y/n) ";;
#  esac
#done

# Install Mediawiki
if [ ! -d "$WIKIDIR" ]; then
  echo "Installing MediaWiki..."

  # Download and extract
  if [ ! -f mediawiki-$WIKIVERSION.tar.gz ]; then
    curl -O http://releases.wikimedia.org/mediawiki/$WIKIVERSIONBRANCH/mediawiki-$WIKIVERSION.tar.gz
  fi
  tar xzf mediawiki-$WIKIVERSION.tar.gz -C ./public
  rm mediawiki-$WIKIVERSION.tar.gz
  mv -i public/mediawiki-$WIKIVERSION $WIKIDIR

  # Config file is stored elsewhere, require it from MW's LocalSettings.php
  cat > public/wiki/LocalSettings.php << EOL
  <?php
  // Load Hitchwiki
  define("HW_ENV", "dev");
  require_once("../../configs/" . HW_ENV . "/mediawiki.php");
  EOL
else
  echo "public/wiki folder already exists. Skipping."
fi

# Install dependencies
echo "Installing dependencies..."
php composer.phar install

echo "Preparing Scotch-box..."
#vagrant up

echo "Prepare development database..."
#create database hitchwiki_wiki_en;
#grant index, create, select, insert, update, delete, alter, lock tables on wikidb.* to 'root'@'localhost' identified by 'root';


# Yay!
echo "Done!"
echo ""
echo "You can run development environment by typing 'vagrant up' and then open http://192.168.33.10/ in your browser."
echo ""
echo "Read more from http://github.com/Hitchwiki/hitchwiki and http://hitchwiki.org/developers"
echo ""
