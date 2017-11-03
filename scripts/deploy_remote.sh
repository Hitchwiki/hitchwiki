USER=hitchwiki
set -e
cd $(dirname $0)/ansible

if [ ! $1 ]
then echo "Usage: Specify one host as parameter. For multiple hosts see INSTALL.md."; exit;
fi
if [ ! -f ~/.ssh/id_rsa.pub ]
then echo "Running 'ssh-keygen' first."; ssh-keygen; fi

echo "Copying public ssh key"
rsync ~/.ssh/id_rsa.pub root@$1:.ssh/authorized_keys
echo "Deploying Hitchwiki on $1"
ansible-playbook deploy.yml --limit=remote
ssh -t hitchwiki@$1 /var/www/scripts/setup_hitchwiki.sh
