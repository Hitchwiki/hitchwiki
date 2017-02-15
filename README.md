# Hitchwiki
_The Hitchhiker's Guide to Hitchhiking the World_

[Hitchwiki](http://hitchwiki.org/) is a collaborative website for
gathering information about
[hitchhiking](http://hitchwiki.org/en/Hitchhiking) and other ways of
extremely cheap ways of transport. It is maintained by many active
hitchhikers all around the world. We have information about how to
hitch out of big cities, how to cover long distances, maps and many
more tips.

## How to help
This version is currently under heavy development in Vilnius, 5.—16.12.2016 by [@simison](https://github.com/simison), [@Remigr](https://github.com/Remigr/) and [@omelnyk](https://github.com/omelnyk/).

_[Contact us](http://hitchwiki.org/en/Template:Communityportal) if you want to join the effort!_

Read more about developing Hitchwiki [from the wiki](https://github.com/Hitchwiki/hitchwiki/wiki)

## Install development environment and start hacking Hitchwiki

### Prerequisites
* A GNU/Linux or OS X machine. Let us know if this works with Cygwin.
* Install [VirtualBox](https://www.virtualbox.org/) ([...because](http://docs.vagrantup.com/v2/virtualbox))
* Install [Vagrant](https://www.vagrantup.com/) ([docs](https://docs.vagrantup.com/v2/installation/))
* Make sure you have [`git`](http://git-scm.com/) installed on your system. (`git --version`)

### Install
1. Clone the repo: `git clone https://github.com/Hitchwiki/hitchwiki.git && cd hitchwiki`
2. Type `bash scripts/vagrant/install.sh`. Make sure not to leave out the `vagrant/` part.
3. Install will ask for your password to add "hitchwiki.dev" to your hosts file.
To skip this and use [http://192.168.33.10/](http://192.168.33.10/) instead,
set `config.hostmanager.enabled = false` at [Vagrant file](Vagrantfile) and copy `configs/settings-example.ini` to `configs/settings.ini` and change domain also from there before installing.
You can [modify your sudoers file](https://github.com/smdahlen/vagrant-hostmanager#passwordless-sudo)
to stop Vagrant asking for password each time.
4. Open [http://hitchwiki.dev/](http://hitchwiki.dev/) in your browser.

After setup your virtual machine is running. Suspend the virtual machine by typing `vagrant suspend`.
When you're ready to begin working again, just run `vagrant up`.

#### Install script will do the following:
* Install [Vagrant hostmanager](https://github.com/smdahlen/vagrant-hostmanager) plugin
* Setup Vagrant box
* Download and extract [Mediawiki](https://www.mediawiki.org/)
* Install dependencies with Composer
* Create a database and configure MediaWiki
* Import pages from `./scripts/pages/`
* Create three users (see below)
* Install Parsoid and VisualEditor
*

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

## Vagrant box

We're using [Scotchbox](http://box.scotch.io/).

### SSH into Vagrant
```bash
vagrant ssh
```

You're probably most interested in folder `/var/www/`

### Database access
#### From the app
Setting | Value
------------ | -------------
User | root
Pass | root
Host | localhost

#### From desktop
Only via SSH Forwarding.

Setting | Value
------------ | -------------
User | root
Pass | root
Host | localhost
SSH Host | 192.168.33.10
SSH User | vagrant
SSH Password | vagrant

### Clean Vagrant box
If for some reason you want to have clean ScotchBox, database and MediaWiki installed, run:
```bash
vagrant destroy && vagrant up
```

## Setting up production environment
_TODO_

## License
Code [MIT](LICENSE.md)
Contents [Creative Commons](http://creativecommons.org/licenses/by-sa/4.0/)

## See also
Our custom MediaWiki extensions:
- [HWMap-extension](https://github.com/Hitchwiki/HWMap-extension)
- [HWRatings-extension](https://github.com/Hitchwiki/HWRatings-extension)
- [HWWaitingTime-extension](https://github.com/Hitchwiki/HWWaitingTime-extension)
- [HWComments-extension](https://github.com/Hitchwiki/HWComments-extension)
- [HWLocationInput-extension](https://github.com/Hitchwiki/HWLocationInput-extension)
- [HitchwikiVector-extension](https://github.com/Hitchwiki/HitchwikiVector-extension)
- [BetaFeatureEverywhere](https://github.com/Hitchwiki/BetaFeatureEverywhere)

Our fork of an abandoned extension:
- [HWVectorBeta](https://github.com/Hitchwiki/mediawiki-extensions-VectorBeta) (previously `VectorBeta`)
