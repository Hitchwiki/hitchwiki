Script | Purpose
------------ | -------------
export_db.sh | export database of the English Hitchwiki from an SQL dump
export_pages.sh | export Hitchwiki pages related to Semantic MediaWiki (forms, templates, etc.)
import_pages.sh | import Hitchwiki pages related to Semantic MediaWiki (forms, templates, etc.)
install.sh | install Hitchwiki inside a Vagrant box
migrate.sh | export databases from old Hitchwiki SQL dumps; bring them up to date with MediaWiki version
path_resolve.sh | set path variables; usage: _"source scripts/path_resolve.sh"_ in bash scripts
permissions.sh | set straight file permissions
pull_hw_extensions.sh | pull custom MediaWiki extensions and update their assets
settings.sh | set config variables (database, site name, etc.); usage: _"source scripts/settings.sh"_
update.sh	 | update MediaWiki, its database, extensions and assets
vagrant_bootstrap.sh | install script to be run inside Vagrant
vagrant_export_pages.sh | run _export_pages.sh_ inside a Vagrant box
vagrant_import_pages.sh | run _import_pages.sh_ inside a Vagrant box
vagrant_migrate.sh | run _migrate.sh_ inside a Vagrant box
vagrant_update.sh | run _update.sh_ inside a Vagrant box
