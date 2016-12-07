#!/bin/bash

echo ""
echo "Install Parsoid..."

#sudo apt-key advanced --keyserver pgp.mit.edu --recv-keys 90E9F83F22250DD7
#sudo apt-add-repository "deb https://releases.wikimedia.org/debian jessie-mediawiki main"
#sudo apt-get install apt-transport-https
#sudo apt-get update && sudo apt-get install parsoid

node --version # should be v0.8 or higher (0.10 or higher is preferred)
git clone --single-branch https://gerrit.wikimedia.org/r/p/mediawiki/services/parsoid

# Copy our settings for Parsoid (replace hitchwiki.dev domain with domain variable from settings.ini)
echo ""
echo "Setup Parsoid configs..."
localsettingsjs=$(<"$SCRIPTDIR/configs/parsoid_localsettings.js")
sudo mkdir -p /etc/mediawiki/parsoid/
sudo echo "${localsettingsjs//hitchwiki.dev/$HW__general__domain}" > /etc/mediawiki/parsoid/localsettings.js

sudo /bin/cp -f "$SCRIPTDIR/configs/parsoid_initscript" /etc/default/parsoid
  
# Restart Parsoid to get new settings affect
echo ""
echo "Restart Parsoid to get new settings affect..."
sudo service parsoid restart
