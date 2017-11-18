#!/bin/bash
USER=hitchwiki
APT="python-simplejson git python-pip unattended-upgrades composer npm tmux python-pip vim monit curl git unzip zip imagemagick build-essential python-software-properties fail2ban htop backupninja ack-grep nano emacs24-nox nullmailer w3m php-apcu zsh apache2 phpmyadmin php7.0 libapache2-mod-php7.0 php7.0-mysql php7.0-curl php7.0-gd php7.0-intl php7.0-imap php7.0-mcrypt php7.0-pspell php7.0-recode php7.0-sqlite3 php7.0-tidy php7.0-xmlrpc php7.0-xsl php7.0-mbstring php7.0-opcache php-memcache php-pear php-imagick php-apcu php-gettext php-xml php-json nodejs mariadb-server software-properties-common python-mysqldb parsoid"
PATHS="/var/www /home/$USER /etc/ansible /etc/monit /etc/letsencrypt /etc/apache2 /etc/mediawiki /etc/init.d/maildev /etc/init.d/parsoid"
echo "This will:
- run './scripts/stop_all.sh'
- remove following paths: $PATHS
- purge following packages: $APT
- remove user $USER"
if [[ $(whoami) != "root" ]]; then echo "Please run this as root."; exit 1; fi
if [[ "$1" -ne '-y' ]]
then echo "Press <ENTER> to contiue or CTRL+C to abort."
read
fi
#set -e
cd $(dirname $0)/..
./scripts/stop_all.sh || echo "Failed to stop all services."
echo "Purging $APT"
apt-get -yq purge $APT
apt-get -y autoremove
apt-get -y autoclean
echo "Removing $PATHS"
rm -fr $PATHS
deluser $USER
