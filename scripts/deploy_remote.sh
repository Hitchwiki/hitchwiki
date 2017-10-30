USER=hitchwiki
set -e
cd $(dirname $0)/ansible

if [ ! $1 ]
then echo "Usage: Specify one host as parameter. For multiple hosts see INSTALL.md."
fi
if [ ! -f ~/.ssh/id_rsa.pub ]
then echo "Running 'ssh-keygen' first."; ssh-keygen; fi

echo "Copying public ssh key"
rsync ~/.ssh/id_rsa.pub root@$1:.ssh/authorized_keys
echo "Deploying Hitchwiki on $1"
ansible-playbook deploy_remote.yml
