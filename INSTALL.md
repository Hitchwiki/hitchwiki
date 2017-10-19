# Running Hitchwiki locally

_These instructions are for installing locally and manually (updating might be tedious). If you'd like to have virtualized setup, see [INSTALL-vagrant.md](INSTALL-vagrant.md) instead._

## Prerequisites

Make sure you have installed all these prerequisites:
* mysql
* apache2
* php
* git

Run as root:
```bash
apt-get install sudo apache2 mysql-server libapache2-mod-php5 git npm php5-mysql
a2enmod rewrite
npm install -g npm
ln -s /usr/bin/nodejs /usr/bin/node
curl -sS https://getcomposer.org/installer | php
sudo mv composer.phar /usr/local/bin/composer
```

Somewhere in your system run:
```bash
git clone https://framagit.org/c1000101/devops.git
```

This will download and install mediawiki:
```bash
cd /var/www/
composer install_local
```

## Installing locally
1. Create user with database
2. Copy `configs/settings-example.yml` to `configs/settings.yml` and edit if necessary
3. Run the install script to deploy Hitchwiki to `public/`:
```bash
composer install_local
```

#### Update local installation
1. Run `git pull` and check for changes
2. It might be enough to run `scripts/updates.sh` to update MediaWiki, the database, extensions and assets
3. Now you can just do:
 `composer clean && composer install_local`
