#!/bin/bash

# Parsoid is NodeJS service used by VisualEditor
# https://www.mediawiki.org/wiki/Parsoid/Setup

echo ""
echo "INSTALLING PARSOID..."

source "scripts/_path_resolve.sh"

# Makes sure we have settings.ini and "Bash ini parser"
source "$SCRIPTDIR/_settings.sh"

# Fixes possible "warning: Setting locale failed." errors
export LC_ALL="en_US.UTF-8"
export LANGUAGE="en_US.UTF-8"

echo ""
echo "Node version:"
node --version # should be v0.8 or higher (0.10 or higher is preferred)

echo ""
echo "Import the repository gpg key: (key updated on July 27, 2016)"
sudo apt-key advanced --keyserver pgp.mit.edu --recv-keys 90E9F83F22250DD7

echo ""
echo "Add the Wikimedia repository..."
sudo apt-add-repository "deb https://releases.wikimedia.org/debian jessie-mediawiki main"
#sudo echo "deb https://releases.wikimedia.org/debian jessie-mediawiki main" > /etc/apt/sources.list.d/parsoid.list

echo ""
echo "Install Parsoid using apt-get..."
sudo apt-get install -y --no-install-recommends apt-transport-https
sudo apt-get -qq update
sudo apt-get install -y --no-install-recommends parsoid

# Copy our settings for Parsoid
echo ""
echo "Setup Parsoid configs..."
parsoid_config=$(<"$SCRIPTDIR/configs/parsoid_config.yaml")
sudo mkdir -p /etc/mediawiki/parsoid/
sudo chown $(whoami) /etc/mediawiki/parsoid
sudo chown $(whoami) /etc/mediawiki/parsoid/config.yaml
# Replace "hitchwiki.dev" with domain variable from settings.ini
sudo echo "${parsoid_config//hitchwiki.dev/$HW__general__domain}" > /etc/mediawiki/parsoid/config.yaml

echo ""
echo "Create Parsoid init script..."
sudo /bin/cp -f "$SCRIPTDIR/configs/parsoid_initscript" /etc/default/parsoid

# Restart Parsoid to get new settings affect
echo ""
echo "Restart Parsoid to get new settings affect..."
sudo service parsoid restart
