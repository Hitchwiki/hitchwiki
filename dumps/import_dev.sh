#!/bin/bash

# Prepare databases
mysql -u root -proot < /var/www/dumps/hitchwiki_db.sql

# Import dev mediawiki SQL dump
mysql -u root -proot hitchwiki < /var/www/dumps/mediawiki-dev.sql

# And we're done!
