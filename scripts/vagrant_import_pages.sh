#!/bin/bash

# Import Hitchwiki pages related to SemanticMediaWiki (forms, templates etc)

SCRIPTSDIR=/var/www/scripts
PAGESDIR=$SCRIPTSDIR/pages
WIKIDIR=/var/www/public/wiki

echo "Importing Semantic content..."

cd $WIKIDIR

# Loop them trough and import to mediawiki using https://www.mediawiki.org/wiki/Manual:Edit.php
#
# Parameter      Description
# --------------------------
# -u <user>	     Username
# -s <summary>   Edit summary
# -m	           Minor edit
# -b	           Bot (hidden) edit
# -a	           Enable autosummary
# --no-rc	       Do not show the change in recent changes

# Determine which pages to import
if [ -z ${1+x} ]; then

  # Check if list file exists
  if [ ! -f $PAGESDIR/_pagelist.txt ]; then
    echo "ERROR: $PAGESDIR/pagelist.txt does not exist! Aborting."
    exit 1
  fi

  # Return lines from the file into $MAPFILE array
  source $SCRIPTSDIR/vendor/filelines2array.sh
  fileLines2Array $PAGESDIR/_pagelist.txt
else
  # Import only asked pages
  MAPFILE=($1)
fi

# Loop array trough
let i=0
for l in "${MAPFILE[@]}"
do

  PAGE=${MAPFILE[$i]}

  echo "Importing '$PAGE'..."

  if [ -z "${PAGE}" ]; then
    echo "-> ERROR: Filename empty!"
    continue
  fi

  if [ -f $PAGESDIR/$PAGE ]; then
    php maintenance/edit.php --no-rc -u Hitchbot -b -s "Importing semantic structure." $PAGE < $PAGESDIR/$PAGE
    php maintenance/protect.php --user Hitchbot $PAGE
  else
    echo "-> ERROR: Could not load file contents for '$PAGE' - file does not exist."
    echo ""
  fi

    let i++
done

echo ""
echo "All done!"
echo ""
