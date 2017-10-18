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

echo "Checking for necessary software ..."
declare -A steps
steps=([pip]="sudo easy_install pip" [vagrant]="echo 'See https://www.vagrantup.com/downloads.html' && exit" [ansible]="sudo pip install ansible")
for pkg in pip ansible vagrant; do
bin=$(which $pkg)
if [[ $bin ]]; then
  echo "  $pkg: $bin"
else
  echo -e "\nNeed to install $pkg."
  eval ${steps[$pkg]}
  bin=$(which $pkg)
  if [[ ! $bin ]] ; then
    echo "Failed to install $pkg. Please run '${steps[$pkg]}' manually."
    exit
  fi
fi
done
unset steps

echo -e $sep
echo "All fine, let's roll ..."
vagrant plugin install vagrant-hostmanager

echo -e $sep
echo "Now watch Vagrant and Ansible ...
To learn how it works see Vagrantfile or https://www.vagrantup.com/docs/provisioning/ansible_intro.html."
vagrant up
vagrant provision
