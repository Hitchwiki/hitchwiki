#!/bin/bash

#
# Export Hitchwiki pages related to Semantic MediaWiki (forms, templates etc)
#

if [ ! -f Vagrantfile ]; then # an arbirtrary file that appears only once in the whole repository tree
    echo "ERROR: Bad working directory ($(pwd))."
    echo "Scripts have to be run from the root directory of the hitchwiki repository."
    echo "Aborting."
    exit 1
fi

source "scripts/_path_resolve.sh"

echo "Exporting Semantic content..."

cd "$WIKIDIR"

# Determine which pages to export
if [ -z "${1+x}" ]; then

  # Check if list file exists
  if [ ! -f "$PAGESDIR/_pagelist.txt" ]; then
    echo "ERROR: $PAGESDIR/_pagelist.txt does not exist! Aborting."
    exit 1
  fi

  # Return lines from the file into $MAPFILE array
  source "$SCRIPTDIR/vendor/filelines2array.sh"
  fileLines2Array "$PAGESDIR/_pagelist.txt"
else
  # Import only asked pages
  MAPFILE=("$1")
fi

# Loop through pages and import them to mediawiki using https://www.mediawiki.org/wiki/Manual:GetText.php
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
