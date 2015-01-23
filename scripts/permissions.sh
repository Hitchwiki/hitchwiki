#!/bin/bash

cd "$(dirname $0)/.."
chgrp -R hitchwiki .
chmod -R g+rw .

chown -R www-data:hitchwiki public/wiki/images
chmod -R ug+rw public/wiki/images
