#!/bin/bash
# executed on control machine
USER=hitchwiki
set -e
cd $(dirname $0)/ansible

if [ ! $1 ]
then echo "Usage: Specify one host as parameter. For multiple hosts see INSTALL.md."; exit;
fi
host=$1

echo "Copy public ssh key"
if [ ! -f ~/.ssh/id_rsa.pub ]
then echo "Running 'ssh-keygen' first."; ssh-keygen; fi
rsync ~/.ssh/id_rsa.pub root@$host:.ssh/authorized_keys

echo "Prepare $host"
ansible-playbook deploy.yml --limit=remote -b -u root

echo "Setup hitchwiki"
ssh -t hitchwiki@$host /var/www/scripts/setup_hitchwiki.sh

exit 0
