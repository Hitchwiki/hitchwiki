#!/bin/bash

# Prepare databases
mysql -u root -proot < /var/www/dumps/hitchwiki_db.sql

# Import dev mediawiki SQL dump
zcat /var/www/dumps/hitchwiki_dev.sql.gz | mysql -u root -proot hitchwiki

# And we're done!
