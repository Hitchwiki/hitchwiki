#!/bin/bash

#
# Migrate old Hitchwiki database into the new system
#
# [!] Existing database will be dropped, so use with caution
#
# Make sure to upgrade your existing Hitchwiki installation to MediaWiki 1.28
# before generating the database dumps for this script
#

if [ ! -f Vagrantfile ]; then # an arbirtrary file that appears only once in the whole repository tree
    echo "ERROR: Bad working directory ($(pwd))."
    echo "Scripts have to be run from the root directory of the hitchwiki repository."
    echo "Aborting."
    exit 1
fi

source "scripts/_path_resolve.sh"
source "$SCRIPTDIR/_settings.sh"

# Exit on error
set -e

echo "Remove existing Hitchwiki images folder..."
rm -rf "$WIKIDIR/images"
echo

echo "Extract old English Hitchwiki images tarball..."
DUMPFILE="$ROOTDIR/dumps/old-images.tar.gz"
if [ ! -f "$DUMPFILE" ]; then
    echo "File $DUMPFILE not found"
    exit 1
fi
tar -xzf "$DUMPFILE" -C "$WIKIDIR"
echo

DUMPFILE="$ROOTDIR/dumps/old-hitchwiki.sql"
if [ -f $DUMPFILE ]; then # single SQL dump with all the databases
    echo "Drop $HW__db__database database..."
    mysql -u$HW__db__username -p$HW__db__password -e "DROP DATABASE IF EXISTS $HW__db__database"
    echo

    echo "Drop hitchwiki_maps database..."
    mysql -u$HW__db__username -p$HW__db__password -e "DROP DATABASE IF EXISTS hitchwiki_maps"
    echo

    echo "Drop hitchwiki_rate database..."
    mysql -u$HW__db__username -p$HW__db__password -e "DROP DATABASE IF EXISTS hitchwiki_rate"
    echo

    echo "Import Hitchwiki multi-database dump..."
    cat "$DUMPFILE" | mysql -u$HW__db__username -p$HW__db__password
    echo
else # one SQL dump per each database
    echo "Drop $HW__db__database database and recreate it..."
    mysql -u$HW__db__username -p$HW__db__password -e "DROP DATABASE IF EXISTS $HW__db__database"
    mysql -u$HW__db__username -p$HW__db__password -e "CREATE DATABASE $HW__db__database CHARACTER SET utf8 COLLATE utf8_general_ci"
    echo

    echo "Import hitchwiki_en SQL dump..."
    DUMPFILE="$ROOTDIR/dumps/old-hitchwiki_en.sql"
    if [ ! -f "$DUMPFILE" ]; then
        echo "File $DUMPFILE not found"
        exit 1
    fi
    cat "$DUMPFILE" | mysql -u$HW__db__username -p$HW__db__password $HW__db__database
    echo

    echo "Drop hitchwiki_maps database and recreate it..."
    mysql -u$HW__db__username -p$HW__db__password -e "DROP DATABASE IF EXISTS hitchwiki_maps"
    mysql -u$HW__db__username -p$HW__db__password -e "CREATE DATABASE hitchwiki_maps CHARACTER SET utf8 COLLATE utf8_general_ci"
    echo

    echo "Import old hitchwiki_maps SQL dump..."
    DUMPFILE="$ROOTDIR/dumps/old-hitchwiki_maps.sql"
    if [ ! -f "$DUMPFILE" ]; then
        echo "File $DUMPFILE not found"
        exit 1
    fi
    cat "$DUMPFILE" | mysql -u$HW__db__username -p$HW__db__password hitchwiki_maps
    echo

    echo "Drop hitchwiki_rate database and recreate it..."
    mysql -u$HW__db__username -p$HW__db__password -e "DROP DATABASE IF EXISTS hitchwiki_rate"
    mysql -u$HW__db__username -p$HW__db__password -e "CREATE DATABASE hitchwiki_rate CHARACTER SET utf8 COLLATE utf8_general_ci"
    echo

    echo "Import old hitchwiki_rate SQL dump..."
    DUMPFILE="$ROOTDIR/dumps/old-hitchwiki_rate.sql"
    if [ ! -f "$DUMPFILE" ]; then
        echo "File $DUMPFILE not found"
        exit 1
    fi
    cat "$DUMPFILE" | mysql -u$HW__db__username -p$HW__db__password hitchwiki_rate
    echo
fi

echo "Drop hitchwiki_migrate database and recreate it..."
mysql -u$HW__db__username -p$HW__db__password -e "DROP DATABASE IF EXISTS hitchwiki_migrate"
mysql -u$HW__db__username -p$HW__db__password -e "CREATE DATABASE hitchwiki_migrate CHARACTER SET utf8 COLLATE utf8_general_ci"
echo

echo "Update MediaWiki..."
cd "$WIKIDIR"
php maintenance/update.php --quick --conf "$MWCONFFILE"
echo

# Pre-populate the antispoof (MW extension) table with your wiki's existing usernames
echo "Pre-populate antispoof table..."
cd "$WIKIDIR"
php extensions/AntiSpoof/maintenance/batchAntiSpoof.php
echo

# Import Semantic pages
cd "$ROOTDIR"
bash "$SCRIPTDIR/import_pages.sh"

echo "Import interwiki table..."
mysql -u$HW__db__username -p$HW__db__password $HW__db__database < "$SCRIPTDIR/configs/interwiki.sql"
echo

# Create basic users
cd "$ROOTDIR"
bash "$SCRIPTDIR/create_users.sh"

# Install dependencies of migrate bot
echo "Install dependencies of migrate bot..."
bash "$SCRIPTDIR/bot/bot_install.sh"
echo

# Make terminal Unicode-friendly for migrate bot's output
echo 'Set en_US.utf8 locale...'
export LC_ALL='en_US.utf8'

# Process MediaWiki job queue before replenishing it
cd "$ROOTDIR"
bash "$SCRIPTDIR/run_mw_jobs.sh"

# Run article migrate bot
echo "Run article migrate bot: annotate place articles with geographical Semantic MW templates (this might take a while)..."
cd "$SCRIPTDIR/bot"
python pywikibot-core/pwb.py migrate/articlemigrate.py
echo

# Process MediaWiki job queue; it gets massive after article migration
cd "$ROOTDIR"
bash "$SCRIPTDIR/run_mw_jobs.sh"

# Run spot migrate bot
echo "Run spot migrate bot: turn spots from the old hitchwiki_maps DB into Semantic MW articles (this might take a while)..."
cd "$SCRIPTDIR/bot"
python pywikibot-core/pwb.py migrate/spotmigrate.py
echo

# Process MediaWiki job queue; it gets massive after spot migration
cd "$ROOTDIR"
bash "$SCRIPTDIR/run_mw_jobs.sh"

# Run extra migrate bot
echo "Run extra migrate bot: copy comments, ratings and waiting times from the old DB tables into the new DB..."
cd "$SCRIPTDIR/bot"
python pywikibot-core/pwb.py migrate/extramigrate.py
echo

# Process MediaWiki job queue, just in case
cd "$ROOTDIR"
bash "$SCRIPTDIR/run_mw_jobs.sh"

# Drop hitchwiki_maps DB
echo "Drop no longer needed hitchwiki_maps database..."
mysql -u$HW__db__username -p$HW__db__password -e "DROP DATABASE IF EXISTS hitchwiki_maps"
echo

# Drop hitchwiki_rate DB
echo "Drop no longer needed hitchwiki_rate database..."
mysql -u$HW__db__username -p$HW__db__password -e "DROP DATABASE IF EXISTS hitchwiki_rate"
echo

# Don't drop hitchwiki_migrate database until we're sure migration is fully done
# mysql -u$HW__db__username -p$HW__db__password -e "DROP DATABASE IF EXISTS hitchwiki_migrate"
# echo

# Process MediaWiki job queue, just in case
cd "$ROOTDIR"
bash "$SCRIPTDIR/run_mw_jobs.sh"

echo "Done! Grrrreat success."
echo
