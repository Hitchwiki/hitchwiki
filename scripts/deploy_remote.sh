USER=hitchwiki
set -e
cd $(dirname $0)/ansible

if [ ! $1 ]
then echo "Usage: Specify one host as parameter. For multiple hosts see INSTALL.md. Set 'REMOTE_USER' to not use default: $USER"; exit 1; fi
HOST=$1
if [ $REMOTE_USER ]
then USER=$REMOTE_USER; fi

if [ ! -f ~/.ssh/id_rsa.pub ]
then echo "Running 'ssh-keygen' first."; ssh-keygen; fi
echo "Copying public ssh key"
rsync ~/.ssh/id_rsa.pub root@$HOST:.ssh/authorized_keys
echo "Deploying Hitchwiki on $HOST"
ansible-playbook deploy_remote.yml

