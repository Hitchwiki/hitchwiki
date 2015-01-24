#!/bin/bash

# Export Hitchwiki pages related to SemanticMediaWiki (forms, templates etc)

source "scripts/path_resolve.sh"

cd "$WIKIDIR"

echo "Exporting Semantic content..."

# Determine which pages to export
if [ -z "${1+x}" ]; then

  # Check if list file exists
  if [ ! -f "$PAGESDIR/_pagelist.txt" ]; then
    echo "ERROR: $PAGESDIR/pagelist.txt does not exist! Aborting."
    exit 1
  fi

  # Return lines from the file into $MAPFILE array
  source "$SCRIPTDIR/vendor/filelines2array.sh"
  fileLines2Array "$PAGESDIR/_pagelist.txt"
else
  # Import only asked pages
  MAPFILE=("$1")
fi

# Loop trough pages and import them to mediawiki using https://www.mediawiki.org/wiki/Manual:Edit.php
let i=0
for l in "${MAPFILE[@]}"
do

  PAGE="${MAPFILE[$i]}"

  echo "Exporting '$PAGE'..."

  if [ -z "${PAGE}" ]; then
    echo "-> ERROR: Filename empty!"
    continue
  fi

  php maintenance/getText.php "$PAGE" >"$PAGESDIR/$PAGE"

  let i++
done

echo ""
echo "All done!"
echo ""
