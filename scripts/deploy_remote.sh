#!/bin/bash
# executed on control machine
starttime=$(date +%s)
set -ev
if [ ! -d $(dirname $0)/ansible ]; then echo "Directory ansible not found. Something is wrong. Exiting."; exit 1; fi
if [ ! $1 ]; then echo -e "Usage: $(basename $0) HOST [PORT]\nSpecify one host as parameter. To deploy multiple hosts see https://github.com/Hitchwiki/hitchwiki/blob/master/INSTALL.md"; exit; fi
cd $(dirname $0)/ansible
HOST=$1
PORT=$2
REPO=https://github.com/traumschule/hitchwiki
VERSION=ansible
WEBROOT=/var/www
DEPS="git python-pip openssh-client sudo at tmux"
PULL_ARGS="-U $REPO -C $VERSION -d $WEBROOT -i /etc/ansible/hosts scripts/ansible/hitchwiki.yml"
# accept user settings
[ -n "$DEPLOY_REPO" ] && REPO=$DEPLOY_REPO
[ -n "$DEPLOY_VERSION" ] && VERSION=$DEPLOY_VERSION
[ -n "$DEPLOY_WEBROOT" ] && WEBROOT=$DEPLOY_WEBROOT
[ -n "$DEPLOY_DEPS" ] && DEPS="$DEPS $DEPLOY_DEPS"
echo "Settings:"
for var in REPO VERSION WEBROOT DEPS; do echo "  $var=${!var}"; done

echo "Copy public ssh key"
if [ ! -f ~/.ssh/id_rsa.pub ]
then echo "Running 'ssh-keygen' first."; ssh-keygen; fi
rsync ~/.ssh/id_rsa.pub root@$HOST:.ssh/authorized_keys

echo "Starting deployment to $HOST"
ssh -t root@$HOST "apt-get update -qq && apt-get install -y $DEPS
  [ -d /etc/ansible ] || mkdir /etc/ansible
  echo 'localhost ansible_connection=local' > /etc/ansible/hosts
  tmux -c 'pip install -U pip && pip install ansible &&
  ANSIBLE_FORCE_COLOR=1 ansible-pull $PULL_ARGS &&
  curl -s localhost'"
endtime=$(date +%s)
min=$((endtime-starttime) / 60)))
sec=$((endtime-starttime) % 60)))
echo "Installed Hitchwiki in $min minutes and $sec seconds."
