#!/bin/bash

# Hitchwiki export script
if [ -z ${1+x} ]; then
  vagrant ssh -c "bash /var/www/scripts/vagrant_export_pages.sh"
else
  vagrant ssh -c "bash /var/www/scripts/vagrant_export_pages.sh $1"
fi
