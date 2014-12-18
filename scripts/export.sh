#!/bin/bash

# Hitchwiki export script

echo ""
echo "Exporting Semantic content..."
vagrant ssh -c "bash /var/www/scripts/vagrant_export_pages.sh"

echo ""
echo "All done!"
