#!/bin/bash

#
# Hitchwiki installation script
#
# Setting up hitchwiki in a vm using vagrant
#

set -e
# set -o errexit # abort on nonzero exitstatus
# set -o nounset # abort on unbound variable

# cd into root folder
sudo mkdir -p "/var/www"
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
print_divider

update_system
install_mariadb
install_apache
install_php
install_phpmyadmin
install_composer
install_nodejs
install_bower
print_versions
install_mail_support
install_self_signed_ssl
create_db
install_mediawiki
install_mw_visual_editor
setup_mediawiki
install_parsoid
set_wiki_folder_permissions

print_divider
echo "🎉  Hitchwiki is now installed! 🎉"
echo "---------------------------------"
echo " "
echo " 👍  Apache is up. Open http://$HW__general__domain/ in your browser."
echo " "
echo " 👍  Parsoid is running. Open http://$HW__general__domain:8142 in your browser."
echo " "
echo " 👍  Maildev is running, inspect emails in your browser http://$HW__general__domain:1080"
echo " "
echo " 👍  PHPMyAdmin is running, access database via http://$HW__general__domain/phpmyadmin"
echo " "
echo "Suspend the virtual machine by calling 'vagrant suspend'."
echo "When you're ready to begin working again, just run 'vagrant up'."
echo " "
echo "To re-install, run 'vagrant destroy && vagrant up'."
echo " "
echo "Read more from http://github.com/Hitchwiki/hitchwiki"
echo " "
echo "Good luck! 🍻"
print_divider
exit 0
