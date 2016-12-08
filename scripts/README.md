Scripts have to be run from the root folder of the repository.

### Bash include scripts:

Script | Purpose
------------ | -------------
_path_resolve.sh | set path variables; usage: _"source scripts/path_resolve.sh"_ in bash scripts
_settings.sh | set config variables (database, site name, etc.); usage: _"source scripts/settings.sh"_

### Generic scripts:

Script | Purpose
------------ | -------------
create_users.sh | create Hitchwiki (admin), Hitchhiker and Hitchbot users
export_db.sh | export database of the English Hitchwiki from an SQL dump
export_pages.sh | export Hitchwiki pages related to Semantic MediaWiki (forms, templates, etc.)
import_pages.sh | import Hitchwiki pages related to Semantic MediaWiki (forms, templates, etc.)
install_parsoid.sh | install Parsoid NodeJS service used by VisualEditor
migrate.sh | export DB from old Hitchwiki SQL dumps; bring it up to date with MediaWiki version
permissions.sh | set correct file permissions
pull_hw_extensions.sh | pull custom MediaWiki extensions and update their assets
server_install.sh | install script to be run on the server or upon first boot by Vagrant
update.sh | update MediaWiki, its database, extensions and assets

### Vagrant helper scripts:

Convenience shortcuts to run the above scripts without logging into the Vagrant box:

Script | Purpose
------------ | -------------
vagrant/export_pages.sh | tell Vagrant to  run _export_pages.sh_ inside the virtual machine
vagrant/import_pages.sh | tell Vagrant to run  _import_pages.sh_ inside the virtual machine
vagrant/migrate.sh | tell vagrant to run _migrate.sh_ inside the virtual machine
vagrant/permissions.sh | tell Vagrant to run _permissions.sh_ inside the virtual machine
vagrant/pull_hw_extensions.sh | tell Vagrant to run _pull_hw_extensions.sh_ inside the virtual machine
vagrant/update.sh | tell Vagrant to run _update.sh_ inside the virtual machine

Install/reinstall scripts for the Vagrant box:

Script | Purpose
------------ | -------------
vagrant/install.sh | download scotchbox image, and set up a Vagrant box with hitchwiki
vagrant/reinstall.sh | wipe out old files & vagrant box, then run install script
