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

After setup your virtual machine is running. Suspend the virtual machine by typing `vagrant suspend`.
When you're ready to begin working again, just `vagrant up` to continue and `vagrant provision` if the first run ended with errors.

To add VMs or VPS edit `./hosts`.

#### Install on localhost or remotely
Note that setup scripts are based on Ubuntu.

_TODO update this section to install on localhost_

If you have root access to a machine, you can deploy hitchwiki there:
- Copy `configs/settings.yml` from `configs/settings-example.yml`
- Add the IP address to the `[remote]` section in `hosts`
- Run `ssh-keygen` locally and add it to `/home/root/.ssh/authorized_keys` on your machine.
- Change `configs/authorized_keys`. This file will be copied to `/home/{{ user }}/.ssh/authorized_keys` on the remote machine. For example use `cp ~/.ssh/id_rsa.pub configs/authorized_keys`.
- (optional) Change `user` and `hostname` in `roles/remote/vars/main.yml`
- Add to your local ~/.ssh/config:
    ```
    Host hw-dev
      HostName {{ ip address }}
      User {{ user }} # default: hitchwiki
    ```
- now run `ansible-playbooks deploy_remote.yml`

#### Ansible
To test current ansible development: `git clone https://github.com/traumschule/hitchwiki -b ansible`.

As soon as Vagrant started the machine, [Ansible](https://docs.ansible.com/ansible/latest/intro.html) runs the [Playbook](https://docs.ansible.com/ansible/latest/playbooks_intro.html) `hitchwiki.yml` with the following roles/chapters:

##### common
- Upgrade distribution packages
- Install helpers like composer and node
- Start downloads in background

##### db
- Setup MariaDB

##### web
- Setup Apache2 with PHP7

##### mw
- Download and extract [Mediawiki](https://www.mediawiki.org/)
- Install dependencies with Composer
- Create a database and configure MediaWiki
- Import pages from `./scripts/pages/`
- Create three users (see below)
- Install Parsoid server and VisualEditor extension
- Install Mediawiki extensions

Depending on your connection this will take some time (40mb for MW alone).

When errors happen, fix them in `./roles/*/tasks/main.yml` and check the syntax with
```bash
ansible-playbook hitchwiki.yml --syntax-check
```

Show hosts in the hitchwiki group (configured in `hosts` and `ansible.cfg`):
```bash
ansible hitchwiki --list-hosts
```

Run ansible without `vagrant provision`:
```bash
ansible-playbook hitchwiki.yml
```

There is still a lot to do. Just risk a `rgrep TODO roles`.

#### Pre-created users (user/pass)
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

# HTTPS
To test encryption test provisioning, set `setup_ssl: True` in `settings.yml` (the variable name may change in the future).
- _staging (development)_ uses the legacy `scripts/cert_selfsigned.sh`
- _production_ is configured to test the unreleased [mod_md](https://github.com/icing/mod_md) module to support [ACME in apache 2.4.x](https://letsencrypt.org/2017/10/17/acme-support-in-apache-httpd.html)

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
/scripts/vagrant/clean.sh
```
This will basically run `vagrant destroy` and clean out all the custom files created during previous provision.

## Setting up production environment
_TODO_
