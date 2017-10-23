#!/bin/bash

cd "$(dirname $0)/.."

# Kick start Hitchwiki installation

sep="\n------------------------------------------------------------\n"

echo -e $sep
echo "   o  o o-O-o o-O-o   o-o o  o o       o o-O-o o  o o-O-o"
echo "   |  |   |     |    /    |  | |       |   |   | /    |  "
echo "   O--O   |     |   O     O--O o   o   o   |   OO     |  "
echo "   |  |   |     |    \    |  |  \ / \ /    |   | \    |  "
echo "   o  o o-O-o   o     o-o o  o   o   o   o-O-o o  o o-O-o"
echo ""
echo "     The Hitchhiker's Guide to Hitchhiking the World"
echo -e $sep

echo "Checking system ..."
for app in pip vagrant ansible; do
  bin=$(which $app)
  if [[ ! $bin ]] ; then
    echo "Please install $app."
  else
    echo "  $app=$bin"
  fi
done

echo -e $sep
echo "All fine, let's roll ..."
vagrant plugin install vagrant-hostmanager

# This will go through scripts/server_install.sh on first run
vagrant up
