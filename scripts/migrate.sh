#!/bin/bash

#
# Migrate old Hitchwiki database into the new system
#
# [!] Existing database will be dropped, so use with caution
#

if [ ! -f Vagrantfile ]; then # an arbirtrary file that appears only once in the whole repository tree
    echo "ERROR: Bad working directory ($(pwd))."
    echo "Scripts have to be run from the root directory of the hitchwiki repository."
    echo "Aborting."
    exit 1
fi

source "scripts/_path_resolve.sh"
source "$SCRIPTDIR/_settings.sh"

echo "Drop $HW__db__database database and recreate it..."
mysql -u$HW__db__username -p$HW__db__password -e "DROP DATABASE IF EXISTS $HW__db__database"
mysql -u$HW__db__username -p$HW__db__password -e "CREATE DATABASE $HW__db__database CHARACTER SET utf8 COLLATE utf8_general_ci"
echo ""

echo "Import old English Hitchwiki SQL dump..."
DUMPFILE="$ROOTDIR/dumps/old-hitchwiki_en.sql"
if [ ! -f "$DUMPFILE" ]; then
    echo "File $DUMPFILE not found"
    exit 1
fi
cat "$DUMPFILE" | mysql -u$HW__db__username -p$HW__db__password $HW__db__database
echo ""

echo "Drop hitchwiki_maps database and recreate it..."
mysql -u$HW__db__username -p$HW__db__password -e "DROP DATABASE IF EXISTS hitchwiki_maps"
mysql -u$HW__db__username -p$HW__db__password -e "CREATE DATABASE hitchwiki_maps CHARACTER SET utf8 COLLATE utf8_general_ci"
echo ""

echo "Import old Hitchwiki Maps SQL dump..."
DUMPFILE="$ROOTDIR/dumps/old-hitchwiki_maps.sql"
if [ ! -f "$DUMPFILE" ]; then
    echo "File $DUMPFILE not found"
    exit 1
fi
cat "$DUMPFILE" | mysql -u$HW__db__username -p$HW__db__password hitchwiki_maps
echo ""

echo "Drop hitchwiki_rate database and recreate it..."
mysql -u$HW__db__username -p$HW__db__password -e "DROP DATABASE IF EXISTS hitchwiki_rate"
mysql -u$HW__db__username -p$HW__db__password -e "CREATE DATABASE hitchwiki_rate CHARACTER SET utf8 COLLATE utf8_general_ci"
echo ""

echo "Import old Hitchwiki Rate SQL dump..."
DUMPFILE="$ROOTDIR/dumps/old-hitchwiki_rate.sql"
if [ ! -f "$DUMPFILE" ]; then
    echo "File $DUMPFILE not found"
    exit 1
fi
cat "$DUMPFILE" | mysql -u$HW__db__username -p$HW__db__password hitchwiki_rate
echo ""

echo "Update MediaWiki..."
cd "$WIKIDIR"
php maintenance/update.php --quick --conf "$MWCONFFILE"
echo ""

# Pre-populate the antispoof (MW extension) table with your wiki's existing usernames
echo "Pre-populate antispoof table..."
cd "$WIKIDIR"
php extensions/AntiSpoof/maintenance/batchAntiSpoof.php
echo ""

# Import Semantic pages
cd "$ROOTDIR"
bash $SCRIPTDIR/import_pages.sh

echo "Import interwiki table..."
mysql -u$HW__db__username -p$HW__db__password $HW__db__database < "$SCRIPTDIR/configs/interwiki.sql"
echo ""

#Create basic users
cd "$ROOTDIR"
bash $SCRIPTDIR/create_users.sh

