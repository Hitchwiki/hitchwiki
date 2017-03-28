# Running Hitchwiki locally

_These instructions are for installing locally. If you'd like to have virtualized setup, see [INSTALL-vagrant.md](INSTALL-vagrant.md) instead._


## Prerequisites

Make sure you have installed all these prerequisites:
* mysql
* apache2
* php
* git


sudo apt-get install sudo apache2 mysql-server libapache2-mod-php5 git npm  php5-mysql

npm install -g npm

ln -s /usr/bin/nodejs /usr/bin/node


curl -sS https://getcomposer.org/installer | php

sudo mv composer.phar /usr/local/bin/composer

somewhere in ur system:
git clone https://framagit.org/c1000101/devops.git

cd /var/www/

composer install_local

a2enmod rewrite


## Installing locally
1. Create user with database and edit settings.ini with the correct values

2. run the install script
```bash
composer install_local
```
3. the app will be deployed to public/


#### Update local installation
1. TODO!
2. now you can just do:
 `composer clean && composer install_local`