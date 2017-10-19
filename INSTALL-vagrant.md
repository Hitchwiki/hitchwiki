## Installing using vagrant

### Prerequisites
* A GNU/Linux or OS X machine. Let us know if this works with Cygwin.
* Install [VirtualBox](https://www.virtualbox.org/) ([...because](http://docs.vagrantup.com/v2/virtualbox))
* Install [Vagrant](https://www.vagrantup.com/) v2 ([docs](https://docs.vagrantup.com/v2/installation/))
* Make sure you have [`git`](http://git-scm.com/) installed on your system. (`git --version`)

### Install

1. Clone the repo:
```
git clone https://github.com/Hitchwiki/hitchwiki.git && cd hitchwiki
```
2. If you want to modify any settings before installation, copy files and do modifications to them:
```
cp configs/settings-example.ini configs/settings.ini
cp configs/vagrant-example.yaml configs/vagrant.yaml
```
3. Some of the settings you can modify:
 - If self signed certificate will be installed (i.e. use `https`) (`vagrant.yaml` and `settings.ini`)
 - Domain (`hitchwiki.test` by default) or develop using IP (`192.168.33.10` by default)

#### Install
1. Run the installation script
```bash
./scripts/vagrant/install.sh
```

This will
* Install [Vagrant hostmanager](https://github.com/smdahlen/vagrant-hostmanager) plugin
* Setup Vagrant box (optional)

2. Install will ask for your password to add `hitchwiki.test` to your `/etc/hosts` file.
You can [modify your sudoers file](https://github.com/smdahlen/vagrant-hostmanager#passwordless-sudo) to stop Vagrant asking for password each time.

3. Open [http://hitchwiki.test/](http://hitchwiki.test/) in your browser. [*https*://hitchwiki.test/](https://hitchwiki.test/) works if you set `setup_ssl` to `true` from `configs/vagrant.yaml`

After setup your virtual machine is running. Suspend the virtual machine by typing `vagrant suspend`.
When you're ready to begin working again, just run `vagrant provision`.

#### Ansible
As soon as Vagrant started the machine, [Ansible](https://docs.ansible.com/ansible/latest/intro.html) takes over to configure the system according to the `hitchwiki.yml` [Playbook](https://docs.ansible.com/ansible/latest/playbooks_intro.html):

common
* Upgrade distribution packages
db
* Setup MariaDB
web
* Setup Apache2 with PHP7
* Install composer and nodejs
mw
* Download and extract [Mediawiki](https://www.mediawiki.org/)
* Install dependencies with Composer
* Create a database and configure MediaWiki
* Import pages from `./scripts/pages/`
* Create three users (see below)
* Install Parsoid and VisualEditor
* Install Mediawiki extensions (HWMap, HitchwikiVector, HWRatings, HWLocationInput)

Depending on your connection this will take some time (40mb for MW alone).

When errors happen, fix them in `roles` and check the syntax with
```
ansible-playbook hitchwiki.yml --syntax-check
```

Show hosts in the hitchwiki group (configured in `ansible.cfg`):
```
ansible hitchwiki --list-hosts
```

Run ansible without `vagrant provision`:
```
ansible-playbook hitchwiki.yml
```

There is still a lot to do. Just risk a `rgrep TODO roles`.

#### Pre-created users (user/pass)
* Admin: Hitchwiki / autobahn
* Bot: Hitchbot / autobahn
* User: Hitchhiker / autobahn

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

### Debug
* Enable debugging mode by setting `debug = true` from `./configs/settings.yml`. You'll then see SQL and PHP warnings+errors.
* Use [Debugging toolbar](https://www.mediawiki.org/wiki/Debugging_toolbar) by setting get/post/cookie variable `hw_debug=1`.
* See [EventLogging](https://www.mediawiki.org/wiki/Extension:EventLogging) extension
* When you change Ansible Playbooks, check the syntax with:
```
ansible-playbook hitchwiki.yml --syntax-check
```

### Update
1. Pull latest changes: `git pull origin master`
2. Run update script: `./scripts/vagrant/update.sh`

### Re-Install
2. Run re-install script: `./scripts/vagrant/reinstall.sh`

## More info on vagrant

Read [basics about Vagrant](https://www.vagrantup.com/intro/)

#### SSH into Vagrant
```bash
vagrant ssh
```

This repository's root is visible via `/var/www/` inside the Vagrant machine.

#### Database access
##### From the app
Setting | Value
------------ | -------------
User | root
Pass | root
Host | localhost

##### From desktop
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

#### Clean Vagrant box
If for some reason you want to have clean Vagrant setup, database and MediaWiki installed, run:
```bash
vagrant destroy -f && ./scripts/clean.sh && vagrant up
```

## Setting up production environment
_TODO_
