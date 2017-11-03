# This will execute the status role for all your ./ansible/hosts
set -e
cd $(dirname $0)/ansible
ansible-playbook status.yml # <- read more in ./ansible/status.yml
