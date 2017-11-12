#!/bin/bash
# To be executed via 'ssh -t' or locally
set -e
cd $(dirname $0)/ansible
if [ $(grep localhost hosts |wc -l) == 0 ]
then echo "Please provision/deploy first."; exit 1; fi
ansible-playbook hitchwiki.yml --limit="localhost"
