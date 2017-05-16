#!/bin/bash

#
# Hitchwiki build script
#
# Setting up hitchwiki in your local webserver
#

#fails dramatically on error!
set -e

source "scripts/_path_resolve.sh"

# Makes sure we have settings.ini and "Bash ini parser"
source "$SCRIPTDIR/_settings.sh"

# Make sure we're at right directory
cd "$ROOTDIR"

# Fixes possible "warning: Setting locale failed." errors
export PATH=$PATH:$ROOTDIR/node_modules/.bin/

source "scripts/install_funcs.sh"

# Javascript
# install_bower

#php
# install_mediawiki

#php 
install_mw_visual_editor
# create_db
pre_setup_mediawiki
setup_mediawiki
# install_parsoid TODO: fix parsoid script...
set_permissions

echo
echo
echo "-------------------------------------------------------------------------"
echo
echo "Hitchwiki is now installed!"
echo
echo "in public/. you should now configure your apache to AllowOverride All so it uses the local .htaccess file"
echo
echo "Read more from http://github.com/Hitchwiki/hitchwiki"
echo
