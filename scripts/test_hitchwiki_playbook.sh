#!/bin/bash
set -e
cd $(dirname $0)/ansible
ansible-playbook hitchwiki.yml --check
