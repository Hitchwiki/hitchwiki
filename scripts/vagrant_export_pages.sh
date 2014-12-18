#!/bin/bash

# Export Hitchwiki pages related to SemanticMediaWiki (forms, templates etc)

PAGESDIR=/var/www/scripts/pages
WIKIDIR=/var/www/public/wiki

cd $WIKIDIR

echo "Exporting Semantic content..."

if [ ! -f $PAGESDIR/_pagelist.txt ]; then
  echo "ERROR: $PAGESDIR/pagelist.txt does not exist! Aborting."
  exit 1
fi

# Loop them trough and import to mediawiki using https://www.mediawiki.org/wiki/Manual:Edit.php
#
# Option/Parameter    Description
# -u <user>	          Username
# -s <summary>	      Edit summary
# -m	                Minor edit
# -b	                Bot (hidden) edit
# -a	                Enable autosummary
# --no-rc	            Do not show the change in recent changes
#
# Load page names into array
declare -a PAGES
readarray PAGES < $PAGESDIR/_pagelist.txt

# Loop array trough
let i=0
while (( ${#PAGES[@]} > i )); do
  PAGE=${PAGES[i++]}
  echo "Exporting $PAGE..."
  php maintenance/getText.php "$PAGE" >"$PAGESDIR/$PAGE"
done

echo ""
echo "All done!"
echo ""
