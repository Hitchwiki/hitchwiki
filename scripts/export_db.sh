#!/bin/bash

echo "Exporting database into SQL dump, this might take a while..."

cd /var/www/dumps

# Rename old dump
mv hitchwiki_dev.sql.gz hitchwiki_dev.sql.gz~

# Export
mysqldump -u root -proot hitchwiki | gzip > hitchwiki_dev.sql.gz

# Remove old dump
rm hitchwiki_dev.sql.gz~

echo "And we're done!"
