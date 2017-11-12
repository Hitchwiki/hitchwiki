#!/bin/bash
set -e
cd $(dirname $0)/ansible
set -e
for role in hitchwiki deploy update status; do
ansible-playbook $role.yml --syntax-check
done
for role in hitchwiki deploy update status; do
ansible-playbook $role.yml --check
done
