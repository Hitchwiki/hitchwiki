#!/bin/bash

cd $(dirname $0)/..

# Kick start Hitchwiki installation

echo "------------------------------------------------------------"
echo ""
echo "   o  o o-O-o o-O-o   o-o o  o o       o o-O-o o  o o-O-o"
echo "   |  |   |     |    /    |  | |       |   |   | /    |  "
echo "   O--O   |     |   O     O--O o   o   o   |   OO     |  "
echo "   |  |   |     |    \    |  |  \ / \ /    |   | \    |  "
echo "   o  o o-O-o   o     o-o o  o   o   o   o-O-o o  o o-O-o"
echo ""
echo "     The Hitchhiker's Guide to Hitchhiking the World"
echo ""
echo "------------------------------------------------------------"
echo ""

# Let's roll...
vagrant plugin install vagrant-hostmanager

# This will go trough vagrant_bootstrap.sh on first run
vagrant up
