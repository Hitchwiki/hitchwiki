Scripts have to be run from the root folder of the repository.

### Generic scripts:

Script | Purpose
------------ | -------------
export_db.sh | export database of the English Hitchwiki from an SQL dump
export_pages.sh | export Hitchwiki pages related to Semantic MediaWiki (forms, templates, etc.)
import_pages.sh | import Hitchwiki pages related to Semantic MediaWiki (forms, templates, etc.)
migrate.sh | export old Hitchwiki SQL dumps and images; bring it up to date with the new Semantic MW-based setup
permissions.sh | set correct file permissions
run_mw_jobs.sh | process MediaWiki job queue
update.sh | update MediaWiki, its database, extensions and assets (see _Ansible_ below)

### Vagrant helper scripts:

Convenience shortcuts to run the above scripts without logging into the Vagrant box:

Script | Purpose
------------ | -------------
vagrant/export_pages.sh | tell Vagrant to  run _export_pages.sh_ inside the virtual machine
vagrant/import_pages.sh | tell Vagrant to run  _import_pages.sh_ inside the virtual machine
vagrant/migrate.sh | tell vagrant to run _migrate.sh_ inside the virtual machine
vagrant/permissions.sh | tell Vagrant to run _permissions.sh_ inside the virtual machine
vagrant/update.sh | tell Vagrant to run _update.sh_ inside the virtual machine

Install/reinstall scripts for the Vagrant box:

Script | Purpose
------------ | -------------
vagrant/install.sh | download Vagrant box image, and set up a Vagrant box with Hitchwiki setup (Server software, Mediawiki and Mediawiki-extensions)
vagrant/reinstall.sh | wipe out old files & Vagrant box, then run install script

### Ansible

Files for automated installation reside in _ansible/_, see [INSTALL.md](https://github.com/Hitchwiki/hitchwiki/blob/master/INSTALL.md)

Script | Purpose
------------ | -------------
deploy_remote.sh | Adds local _~/.ssh/id_rsa.pub_ to remote _~/.ssh/authorized_keys_ and runs _ansible/hitchwiki.yml_ playbook on the HOST (given as argument)
logs.sh | Run as root, watches linked logs in _../logs_ in one window for changes (best run in `tmux` or `screen`)
status.sh | Print status report to _/etc/ansible/facts.d/state.yml_ when run as root, otherwise to _ansible/state.yml_
status_all.sh | runs _ansible/status.yml_ playbook for all servers in _ansible/hosts_ and collects their state in _ansible/status/HOSTNAME/_
stop_all.sh | Stop services installed by us
clean_server.sh | Try to remove traces (stop services, remove installed packages, remove configuration files and delete user)
update.sh | Now calls the _ansible/update.yml_ playbook

