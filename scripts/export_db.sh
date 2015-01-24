#!/bin/bash

# Export Hitchwiki database

source "scripts/path_resolve.sh"
source "$SCRIPTDIR/settings.sh"

echo "Exporting database into SQL dump, this might take a while..."
cd "$DUMPSDIR"

# Rename old dump
mv hitchwiki_dev.sql.gz hitchwiki_dev.sql.gz~

# Export
mysqldump -u$HW__db__username -p$HW__db__password $HW__db__database | gzip > hitchwiki_dev.sql.gz

# Remove old dump
rm hitchwiki_dev.sql.gz~

echo "And we're done!"
