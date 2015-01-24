#!/bin/bash

# Export Hitchwiki pages related to SemanticMediaWiki (forms, templates etc)
# when using Vagrant setup

source "scripts/path_resolve.sh"

if [ -z "${1+x}" ]; then
  vagrant ssh -c "bash \"$VAGRANT_SCRIPTDIR/export_pages.sh\""
else
  vagrant ssh -c "bash \"$VAGRANT_SCRIPTDIR/export_pages.sh\" \"$1\""
fi
