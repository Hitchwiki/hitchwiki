# Hitchwiki
_The Hitchhiker's Guide to Hitchhiking the World_

[Hitchwiki](http://hitchwiki.org/) is a collaborative website for gathering information about [hitchhiking](http://hitchwiki.org/en/Hitchhiking) and other ways of extremely cheap ways of transport. It is maintained by many active hitchhikers all around the world. We have information about how to hitch out of big cities, how to cover long distances, maps and many more tips.

# How to help
This version is [currently under heavy developed](https://love.hitchwiki.net/) in Turkey Dec 2014—Feb 2015 by [@simison](https://github.com/simison) and [@Remigr](https://github.com/Remigr/)

_[Contact us](http://hitchwiki.org/developers) if you want to join the effort!_


## Install & start hacking Hitchwiki
_Tested on Ubuntu & OSX._

### Prerequisites
* Install [VirtualBox](https://www.virtualbox.org/) ([...because](http://docs.vagrantup.com/v2/virtualbox))
* Install [Vagrant](https://www.vagrantup.com/) ([docs](https://docs.vagrantup.com/v2/installation/))
* Make sure you have [`git`](http://git-scm.com/), `curl` and `php` in your system.

### Install
1. Clone the repo: `git clone https://github.com/Hitchwiki/hitchwiki.git && cd hitchwiki`
2. Run installation script: `sh ./scripts/install.sh`
3. Run `vagrant up` to run development environment
4. Open [http://192.168.33.10/](http://192.168.33.10/) in your browser

#### This will do the following
* Downloads [Composer](https://getcomposer.org/) into the project
* Download and extract [Mediawiki](https://www.mediawiki.org/)
* Download dependencies with Composer
* Import development database into Scotchbox

### Update
1. Pull latest changes: `git pull origin master`
2. Run update script: `sh ./scripts/update.sh`

### SSH into your server
```bash
vagrant ssh
```

### Pause your server
Do this before turning computer off.
```bash
vagrant suspend
```

### Clean Vagrant box
If for some reason you want to have clean Scotchbox installed, run:
```bash
vagrant destroy
vagrant up
```

## Production environment
_TODO_

### Install
* Install Apache
* Install MySQL or MariaDB
* Install PHP
* Clone the repo: `git clone https://github.com/Hitchwiki/hitchwiki.git && cd hitchwiki`
* Install Composer: `curl -sS https://getcomposer.org/installer | php`
* Install components with Composer `php composer.phar install`


## License
Code [MIT](LICENSE.md)
Contents [Creative Commons](http://creativecommons.org/licenses/by-sa/4.0/)

_Keep up hitching!_
