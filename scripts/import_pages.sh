#!/bin/bash

#
# Import Hitchwiki pages related to Semantic MediaWiki (forms, templates etc)
#

if [ ! -f Vagrantfile ]; then # an arbirtrary file that appears only once in the whole repository tree
    echo "ERROR: Bad working directory ($(pwd))."
    echo "Scripts have to be run from the root directory of the hitchwiki repository."
    echo "Aborting."
    exit 1
fi

source "scripts/_path_resolve.sh"

echo "Importing Semantic content..."

cd "$WIKIDIR"

# Determine which pages to import
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
echo ""

# Loop pages through and import them to mediawiki
let i=0
for l in "${MAPFILE[@]}"
do

  PAGE="${MAPFILE[$i]}"

  echo "Importing '$PAGE'..."

  if [ -z "${PAGE}" ]; then
    echo "-> ERROR: Filename empty!"
    continue
  fi

  if [ -f "$PAGESDIR/$PAGE" ]; then
    # Supported parameters of https://www.mediawiki.org/wiki/Manual:Edit.php:
    #
    # Parameter      Description
    # --------------------------
    # -u <user>      Username
    # -s <summary>   Edit summary
    # -m             Minor edit
    # -b             Bot (hidden) edit
    # -a             Enable autosummary
    # --no-rc        Do not show the change in recent changes
    php maintenance/edit.php --no-rc -u Hitchbot -b -s "Importing semantic structure." "$PAGE" < "$PAGESDIR/$PAGE"

    php maintenance/protect.php --user Hitchbot "$PAGE"
  else
    echo "-> ERROR: Could not load file contents for '$PAGE' - file does not exist."
  fi

  echo ""
  let i++
done

echo "All done!"
echo ""
