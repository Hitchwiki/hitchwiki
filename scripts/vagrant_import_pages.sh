#!/bin/bash

# Import Hitchwiki pages related to SemanticMediaWiki (forms, templates etc)
# when using Vagrant setup

source "scripts/path_resolve.sh"

# Scripts rely on working directory being the root directory of this git repository
if [ -z "${1+x}" ]; then
  vagrant ssh -c "cd \"$VAGRANT_ROOTDIR\" && bash \"$VAGRANT_SCRIPTDIR/import_pages.sh\""
else
  vagrant ssh -c "cd \"$VAGRANT_ROOTDIR\" && bash \"$VAGRANT_SCRIPTDIR/import_pages.sh\" \"$1\""
fi
