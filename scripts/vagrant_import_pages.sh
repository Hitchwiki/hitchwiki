#!/bin/bash

# Hitchwiki import script

if [ -z "${1+x}" ]; then
  vagrant ssh -c "bash /var/www/scripts/import_pages.sh"
else
  vagrant ssh -c "bash /var/www/scripts/import_pages.sh \"$1\""
fi
