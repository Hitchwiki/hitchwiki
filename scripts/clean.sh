#!/bin/bash

#
# Hitchwiki cleaning installation script
#

set -e

source "scripts/_path_resolve.sh"

echo "$WIKIDIR"
rm -rf "$WIKIDIR"
#TODO: remove mysql maybe?
#TODO: undo crazy sed stuff... Map/Map.php
