set -e
dir=$(dirname $0)
cd $dir/..
ansible-playbook ./scripts/deploy.yml
