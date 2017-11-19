#!/bin/bash
# executed on control machine
starttime=$(date +%s)
set -e
function sep() {
  echo -e "\n------------------------------------------------------------\n"
}

sep
echo "   o  o o-O-o o-O-o   o-o o  o o       o o-O-o o  o o-O-o"
echo "   |  |   |     |    /    |  | |       |   |   | /    |  "
echo "   O--O   |     |   O     O--O o   o   o   |   OO     |  "
echo "   |  |   |     |    \    |  |  \ / \ /    |   | \    |  "
echo "   o  o o-O-o   o     o-o o  o   o   o   o-O-o o  o o-O-o"
echo ""
echo "     The Hitchhiker's Guide to Hitchhiking the World"
sep

# set defaults
HOST=$1
PORT=$2
CONFIG="$(dirname $0)/../configs/settings.yml"
[ -n "$DEPLOY_CONFIG" ] && CONFIG=$DEPLOY_CONFIG
REPO=$(grep -A5 'repository:' $CONFIG|grep 'url:'|cut -f4 -d' ') # TODO replace this brittle hack
VERSION=$(grep -A5 'repository:' $CONFIG|grep 'branch:'|cut -f4 -d' ')
WEBROOT=$(grep 'webroot:' $CONFIG|cut -f4 -d' ')
DEPS="git python-pip openssh-client sudo at tmux"
PULL_ARGS="-U $REPO -C $VERSION -d $WEBROOT -i /etc/ansible/hosts scripts/ansible/hitchwiki.yml"
LETSENCRYPT_ARCHIVE="$(dirname $0)/../dumps/letsencrypt.tar.xz"

# accept user settings
[ -n "$DEPLOY_REPO" ] && REPO=$DEPLOY_REPO
[ -n "$DEPLOY_VERSION" ] && VERSION=$DEPLOY_VERSION
[ -n "$DEPLOY_WEBROOT" ] && WEBROOT=$DEPLOY_WEBROOT
[ -n "$DEPLOY_DEPS" ] && DEPS="$DEPS $DEPLOY_DEPS"
[ -n "$DEPLOY_LETSENCRYPT" ] && LETSENCRYPT_ARCHIVE=$DEPLOY_LETSENCRYPT

# verify parameters or print usage
if [ ! -d $(dirname $0)/ansible ]; then echo "Directory ansible not found. Something is wrong. Exiting."; exit 1; else cd $(dirname $0)/ansible; fi
if [ ! -f $CONFIG ] ; then echo "Could not find $CONFIG. Copy settings-example.yml or define DEPLOY_CONFIG."; exit 1; fi
if [ -z $1 ]; then echo "Usage: $0 HOST [PORT]

To deploy multiple hosts see https://github.com/Hitchwiki/hitchwiki/blob/master/INSTALL.md

Adjust $CONFIG or set DEPLOY_CONFIG DEPLOY_REPO DEPLOY_VERSION DEPLOY_WEBROOT DEPLOY_DEPS DEPLOY_LETSENCRYPT to change defaults."; exit 1; fi

echo "Settings:"
for var in CONFIG REPO VERSION WEBROOT DEPS LETSENCRYPT_ARCHIVE; do echo "  $var=${!var}"; done

sep

echo "Copy public ssh key"
if [ ! -f ~/.ssh/id_rsa.pub ]
then echo "Running 'ssh-keygen' first."; ssh-keygen; fi
rsync ~/.ssh/id_rsa.pub root@$HOST:.ssh/authorized_keys

# You can define settings for the host in this file
echo "Copy settings.yml"
rsync $CONFIG root@$HOST:

# If present this archive is transferred and extracted to /etc/letsencrypt
if [ -f $LETSENCRYPT_ARCHIVE ]; then
  if [ $(tar tf $LETSENCRYPT_ARCHIVE|grep 'etc/letsencrypt'|wc -l) == 0 ]; then
    echo "$LETSENCRYPT_ARCHIVE looks corrupt (missing etc/letsencrypt)."; exit 1;
  else
    echo "Copy letsencrypt archive"
    rsync $LETSENCRYPT_ARCHIVE root@$HOST:
  fi
else
  echo "Letsencrypt: $LETSENCRYPT_ARCHIVE not found, skipping."
fi

echo "Starting deployment to $HOST"
ssh -t root@$HOST "set -ev;
  apt-get update &&
  apt-get install -y $DEPS &&
  [ -d /etc/ansible ] || mkdir /etc/ansible;
  echo 'localhost ansible_connection=local' > /etc/ansible/hosts &&
  pip install -U pip &&
  pip install ansible &&
  tmux -c 'ANSIBLE_FORCE_COLOR=1 ansible-pull $PULL_ARGS'"

sep

endtime=$(date +%s)
min=$(((endtime-starttime) / 60))
sec=$(((endtime-starttime) % 60))
echo "Installed Hitchwiki on $HOST in $min minutes and $sec seconds."
