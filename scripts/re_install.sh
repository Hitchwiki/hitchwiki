#!/bin/bash

set -e

clear

echo "Removing previous files and Vagrant machine..."

rm -fr composer.lock && \
rm -fr public/wiki && \
vagrant destroy && \
./scripts/install.sh;
