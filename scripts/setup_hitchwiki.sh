set -e
dir=$(dirname $0)
cd $dir/..
ansible-playbook hitchwiki.yml
