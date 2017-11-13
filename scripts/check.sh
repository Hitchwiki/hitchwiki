#!/bin/bash
# Execute this before you commit changes to ansible or .travis.yml.
# Add 'all' as first parameter to testrun playbooks (--check).
set -e
cd $(dirname $0)/..
if [ -n "$(which travis)" ] ; then
  travis lint
else
  echo "To check the syntax of .travis.yml please run 'gem install travis -v 1.8.8 --no-rdoc --no-ri', depends on ruby: see https://github.com/travis-ci/travis.rb#installation"
  exit 1
fi
cd $(dirname $0)/ansible
set -e
for role in hitchwiki deploy update status; do
ansible-playbook $role.yml --syntax-check
done
if [ "$1" = "all" ] ; then
for role in hitchwiki deploy update status; do
ansible-playbook $role.yml --check
done
fi
