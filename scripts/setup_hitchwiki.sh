#!/bin/bash
# To be executed via 'ssh -t' or locally
set -e
cd $(dirname $0)/ansible
ansible-playbook hitchwiki.yml --limit="localhost"
