#!/bin/bash
set -e
if [[ $(whoami) != "root" ]]; then echo "Please run this as root."; exit; fi
cd $(dirname $0)/..
./scripts/stop_all.sh
apt-get -yq purge python-simplejson git python-pip unattended-upgrades composer npm tmux python-pip vim monit curl git unzip zip imagemagick build-essential python-software-properties fail2ban htop backupninja ack-grep nano emacs24-nox nullmailer w3m php-apcu zsh apache2 phpmyadmin php7.0 libapache2-mod-php7.0 php7.0-mysql php7.0-curl php7.0-gd php7.0-intl php7.0-imap php7.0-mcrypt php7.0-pspell php7.0-recode php7.0-sqlite3 php7.0-tidy php7.0-xmlrpc php7.0-xsl php7.0-mbstring php7.0-opcache php-memcache php-pear php-imagick php-apcu php-gettext php-xml php-json nodejs mariadb-server software-properties-common python-mysqldb python-certbot-apache apt-transport-https parsoid
apt-get -yq autoremove
apt-get -yq autoclean
rm -fr /var/www /home/hitchwiki /etc/monit/monitrc /etc/letsencrypt /etc/apache2 /etc/mediawiki /etc/init.d/{maildev,parsoid} /etc/ansible
deluser hitchwiki
