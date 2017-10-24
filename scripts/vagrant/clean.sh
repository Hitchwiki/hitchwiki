#!/bin/bash

set -e
cd "$(dirname $0)/../.."

if [ ! -f Vagrantfile ]; then # an arbirtrary file that appears only once in the whole repository tree
    echo "ERROR: Bad working directory ($(pwd))."
    echo "Scripts have to be run from the root directory of the hitchwiki repository."
    echo "Aborting."
    exit 1
fi

# Clean out files
./scripts/clean.sh

# Remove vagrant box
vagrant destroy -f
