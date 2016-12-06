#!/bin/bash

set -e

echo "Removing previous files and Vagrant machine..."

rm -fr public/wiki && /
vagrant destroy && /
./scripts/install.sh
