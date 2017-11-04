#!/bin/bash
set -e
USER=hitchwiki
APT="python-simplejson git python-pip unattended-upgrades composer npm tmux python-pip vim monit curl git unzip zip imagemagick build-essential python-software-properties fail2ban htop backupninja ack-grep nano emacs24-nox nullmailer w3m php-apcu zsh apache2 phpmyadmin php7.0 libapache2-mod-php7.0 php7.0-mysql php7.0-curl php7.0-gd php7.0-intl php7.0-imap php7.0-mcrypt php7.0-pspell php7.0-recode php7.0-sqlite3 php7.0-tidy php7.0-xmlrpc php7.0-xsl php7.0-mbstring php7.0-opcache php-memcache php-pear php-imagick php-apcu php-gettext php-xml php-json nodejs mariadb-server software-properties-common python-mysqldb python-certbot-apache apt-transport-https parsoid"
PATHS="/var/www /home/$USER /etc/{ansible,monit,letsencrypt,apache2,mediawiki} /etc/init.d/{maildev,parsoid}"
if [[ $(whoami) != "root" ]]; then echo "Please run this as root.
I will
- run './scripts/stop_all.sh'
- purge following packages: $APT
- remove following paths: $PATHS
- remove user $USER
Be sure that this is your intention."; exit; fi
cd $(dirname $0)/..
./scripts/stop_all.sh
echo "Purging $APT"
apt-get -yqq purge $APT
apt-get -yq autoremove
apt-get -yq autoclean
echo "Removing $PATHS"
rm -fr $PATHS
deluser $USER
echo "Done."
