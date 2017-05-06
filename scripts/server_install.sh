#!/bin/bash

#
# Hitchwiki installation script
#
# Setting up hitchwiki in a vm using vagrant
#

# cd into root folder of the repo
cd "/var/www"

source "scripts/_path_resolve.sh"

# Makes sure we have settings.ini and "Bash ini parser"
source "$SCRIPTDIR/_settings.sh"

# Make sure we're at right directory
cd "$ROOTDIR"

# Fixes possible "warning: Setting locale failed." errors
export LC_ALL="en_US.UTF-8"
export LANGUAGE="en_US.UTF-8"

source "scripts/install_funcs.sh"

print_lamp_versions
install_helper_tools
upgrade_to_gitv2
install_mail_support
install_self_signed_ssl
install_bower
upgrade_composer
create_db
install_mediawiki
install_mw_visual_editor
setup_mediawiki
install_parsoid
set_permissions

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
