## Installing using vagrant

### Prerequisites
1. Install [VirtualBox](https://www.virtualbox.org/)
1. Install [Vagrant](https://www.vagrantup.com/) v2 ([Install docs](https://docs.vagrantup.com/v2/installation/))
1. Make sure you have [`git`](http://git-scm.com/) installed on your system. (`git --version`)
1. Make sure you have [Python](https://www.python.org/) v2 installed on your system. (`python --version`)
1. Install [Ansible](https://www.ansible.com/) v2 ([Install docs](https://docs.ansible.com/ansible/latest/intro_installation.html#installing-the-control-machine))

### Install

1. Clone the repo:
    ```bash
    git clone https://github.com/Hitchwiki/hitchwiki.git && cd hitchwiki
    ```
1. If you want to modify any settings before installation, copy files and do modifications to them:
    ```bash
    cp configs/settings-example.yml configs/settings.yml
    ```
1. Some of the settings you can modify:
    - If self signed certificate will be installed (i.e. use `https`)
    - Domain (`hitchwiki.test` by default) or develop using IP (`192.168.33.10` by default)

#### Install with vagrant
Vagrant set's up and provisions a Vagrant box with [Ansible](https://www.ansible.com/).

1. Run the installation script
    ```bash
    ./scripts/vagrant/install.sh
    ```
1. Install will ask for your password to add `hitchwiki.test` to your `/etc/hosts` file.
You can [modify your sudoers file](https://github.com/smdahlen/vagrant-hostmanager#passwordless-sudo) to stop Vagrant asking for password each time.
1. Open [http://hitchwiki.test/](http://hitchwiki.test/) in your browser. [*https*://hitchwiki.test/](https://hitchwiki.test/) works if you set `setup_ssl` to `true` in `configs/settings.yml`

As soon as Vagrant started the machine, [Ansible](https://docs.ansible.com/ansible/latest/intro.html) runs the [Playbook](https://docs.ansible.com/ansible/latest/playbooks_intro.html) `hitchwiki.yml`.

After setup your virtual machine is running. Suspend the virtual machine by typing `vagrant suspend`.
When you're ready to begin working again, just `vagrant up` to continue and `vagrant provision` if the first run ended with errors.

To add VMs or VPS edit `./hosts`.

##### Update
1. Pull latest changes: `git pull origin master`
2. Run update script: `./scripts/vagrant/update.sh`

##### Re-Install
2. Run re-install script: `./scripts/vagrant/reinstall.sh`

##### More info on vagrant
Read [basics about Vagrant](https://www.vagrantup.com/intro/)

##### SSH into Vagrant
```bash
vagrant ssh
```
This repository's root is visible via `/var/www/` inside the Vagrant machine.

##### Clean Vagrant box
If for some reason you want to have clean Vagrant setup, database and MediaWiki installed, run:
```bash
./scripts/vagrant/clean.sh
```
This will basically run `vagrant destroy` and clean out all the custom files created during previous provision.

#### Run Ansible without vagrant
If you have root access to a remote or local machine, you can deploy hitchwiki there:
```bash
git clone https://github.com/traumschule/hitchwiki -b ansible hitchwiki
cd hitchwiki
```
- Copy `configs/settings-example.yml` to `configs/settings.yml`  and define your `domain` (it will be set as remote hostname and in `/etc/hosts` on the (remote) system). You can change the username with `user` (default: hitchwiki).
- Add the IP address to the `[remote]` section in `hosts`. You can as well use `localhost`:
```
hw-dev ansible_ssh_host={{ remote }} ansible_user=root ansible_ssh_private_key_file=~/.ssh/id_rsa
```
- Run `ssh-keygen` locally
- Add to your local ~/.ssh/config:
```
    Host hw-dev
      HostName {{ remote ip address }}
      User {{ user }} # default: hitchwiki
```
- Add your public key in `~/.ssh/id_rsa.pub` to `configs/authorized_keys` (it will be copied to `/home/{{ user }}/.ssh/authorized_keys` on the remote machine):
```bash
cat ~/.ssh/id_rsa.pub >> configs/authorized_keys
```
- Copy `configs/authorized_keys` (local) to `/home/root/.ssh/authorized_keys` (remote):
```bash
rsync ~/.ssh/id_rsa.pub root@remote:.ssh/authorized_keys
``'
- Prepare the remote system:
```bash
./scripts/deploy_remote.sh # this will run `ansible-playbooks ./scripts/deploy.yml`
```
- Open `hosts` in your preferred editor and move the remote to the '[hitchwiki]' group and run
```bash
ansible-playbook hitchwiki.yml
```
or ssh in before (recommended):
```
ssh user@remote
cd ~/src
./scripts/setup_hitchwiki.sh # this will run `ansible-playbooks hitchwiki.yml`
```

If a chapter ran successfully, it will be skipped next. To rerun the related service needs to be stopped:
- system: remove /etc/ansible/facts.d
- db: stop mariadb
- web: stop apache2
- mw: stop parsoid
- production: stop monit

When errors happen, report them to [our issue tracker](https://github.com/Hitchwiki/hitchwiki/issues) or try to fix (start reading in `hitchwiki.yml` and `roles/hitchwiki/tasks/main.yml`. After changes check the syntax with
```bash
ansible-playbook hitchwiki.yml --syntax-check
```
Show hosts (configured in `hosts`):
```bash
ansible hitchwiki --list-hosts
```
To see open tasks run `rgrep TODO roles` or check the [ansible pull request](https://github.com/Hitchwiki/hitchwiki/pull/167). Note that setup scripts are based on Ubuntu.

##### What ansible does
- Upgrade distribution packages
- Install helpers like composer and node
- Start downloads in background
- Setup MariaDB
- Setup Apache2 with PHP7
- Download and extract [Mediawiki](https://www.mediawiki.org/)
- Install dependencies with Composer
- Create a database and configure MediaWiki
- Import pages from `./scripts/pages/`
- Create three users (see below)
- Install Parsoid server and VisualEditor extension
- Install Mediawiki extensions
Depending on your connection this will take some time (40mb for MW alone).

### Pre-created users (user/pass)
- Admin: Hitchwiki / autobahn
- Bot: Hitchbot / autobahn
- User: Hitchhiker / autobahn

### Export Semantic structure
If you do changes to Semantic structures (forms, templates etc), you should export those files by running:
```bash
./scripts/vagrant/export_pages.sh
```

### Import Semantic structure
This is done once at install, but needs to be done each time somebody changes content inside `./scripts/pages/`. It can be done by running:
```bash
./scripts/vagrant/import_pages.sh
```

### Debugging
* Enable debugging mode by setting `debug = true` from `./configs/settings.yml`. You'll then see SQL and PHP warnings+errors.
* Use [Debugging toolbar](https://www.mediawiki.org/wiki/Debugging_toolbar) by setting get/post/cookie variable `hw_debug=1`.
* See [EventLogging](https://www.mediawiki.org/wiki/Extension:EventLogging) extension
* Add `strategy: debug` to a role to automatically load a (quite limited) [debugger](https://docs.ansible.com/ansible/latest/playbooks_debugger.html) to inspect variables when a task fails.
* Check the syntax of Ansible Playbooks,  with:
    ```bash
    ansible-playbook hitchwiki.yml --syntax-check
    ```

### Security (production environment)
- To enable TLS set `env: production` or `mediawiki.protocol: https` in `configs/settings.yml`. And don't forget to define a valid `domain` to request certificate from letsencrypt. Otherwise a self-signed certificate is created. For details see `roles/hitchwiki/tasks/tls.yml` and included files.
- If you set up letsencrypt before, copy your backup to `/etc/letsencrypt`.
- Change `mediawiki.db.password` in `configs/settings.yml`.
- Change the password in `configs/monitrc`, it will be copied to `/etc/monit/monitrc`.
- Run `ansible-playbook hitchwiki.yml` (again).
- Check that your server redirects to https afterwards.
- Remove `.ssh/id_rsa` from the server.
Database backups are stored in `var/backup/mysql`.

Note: If you had apache2, mysqld, parsoid or monit running before, please stop them during installation, or related tasks will be skipped. They'll be started automatically.

###  Database access
#### From the app
Setting | Value
------------ | -------------
User | root
Pass | root
Host | localhost

#### From desktop
Only via SSH Forwarding. You need to set a password for `ubuntu` user before you can SSH into the box. (Info [via](https://stackoverflow.com/a/41337943/1984644))

Do:
```bash
vagrant ssh
sudo passwd ubuntu
(type ubuntu twice)
```

Setting | Value
------------ | -------------
User | root
Pass | root
Host | localhost
SSH Host | 192.168.33.10
SSH User | ubuntu
SSH Password | ubuntu

## Setting up production environment
Set `env: production` in `configs/settings.yml` run `ansible-playbook hitchwiki.yml`.
