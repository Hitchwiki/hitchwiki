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
1. Start installation script
```bash
./scripts/vagrant/install.sh
```

2. Install will ask for your password to add `hitchwiki.test` to your `/etc/hosts` file.
You can [modify your sudoers file](https://github.com/smdahlen/vagrant-hostmanager#passwordless-sudo) to stop Vagrant asking for password each time.

3. Open [http://hitchwiki.test/](http://hitchwiki.test/) in your browser. [*https*://hitchwiki.test/](https://hitchwiki.test/) works if you set `setup_ssl` to `true` from `configs/vagrant.yaml`

After setup your virtual machine is running. Suspend the virtual machine by typing `vagrant suspend`.
When you're ready to begin working again, just run `vagrant up`.


#### Install script will do the following:
* Install [Vagrant hostmanager](https://github.com/smdahlen/vagrant-hostmanager) plugin
* Setup Vagrant box (optional)
* Download and extract [Mediawiki](https://www.mediawiki.org/)
* Install dependencies with Composer
* Create a database and configure MediaWiki
* Import pages from `./scripts/pages/`
* Create three users (see below)
* Install Parsoid and VisualEditor

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
* Enable debugging mode by setting `debug = true` from `./configs/settings.ini`. You'll then see SQL and PHP warnings+errors.
* Use [Debugging toolbar](https://www.mediawiki.org/wiki/Debugging_toolbar) by setting get/post/cookie variable `hw_debug=1`.
* See [EventLogging](https://www.mediawiki.org/wiki/Extension:EventLogging) extension

### Update
1. Pull latest changes: `git pull origin master`
2. Run update script: `./scripts/vagrant/update.sh`

### Re-Install
2. Run re-install script: `./scripts/vagrant/reinstall.sh`

## More info on vagrant

We're using [Scotchbox](http://box.scotch.io/).

#### SSH into Vagrant
```bash
vagrant ssh
```

You're probably most interested in folder `/var/www/`

#### Database access
##### From the app
Setting | Value
------------ | -------------
User | root
Pass | root
Host | localhost

##### From desktop
Only via SSH Forwarding.

Setting | Value
------------ | -------------
User | root
Pass | root
Host | localhost
SSH Host | 192.168.33.10
SSH User | vagrant
SSH Password | vagrant

#### Clean Vagrant box
If for some reason you want to have clean ScotchBox, database and MediaWiki installed, run:
```bash
vagrant destroy && vagrant up
```

## Setting up production environment
_TODO_
