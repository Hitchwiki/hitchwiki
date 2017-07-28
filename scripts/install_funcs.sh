#!/bin/bash

set -e
# Makes sure we have settings.ini and "Bash ini parser"
source "$SCRIPTDIR/_settings.sh"

#
# Hitchwiki installation functions helper
#

update_system()
{
  echo "Update system & install helper tools"
  sudo apt-get -qq update
  sudo apt-get upgrade -y
  echo "System updated"

  echo "Install `unattended-upgrades`, `fail2ban`"
  sudo apt-get -y install \
    unattended-upgrades \
    vim \
    curl \
    git \
    imagemagick \
    build-essential \
    python-software-properties \
    fail2ban;

  echo "Do apt-get purge & autoremove"
  sudo apt-get --purge autoremove -y
  echo
  echo "-------------------------------------------------------------------------"
}

print_versions()
{
  echo
  echo "System versions:"
  echo
  apache2 -version
  echo
  mysql -V
  echo
  php -v
  echo
  npm --version
  echo
  node --version
  echo
  bower --version
  echo
  openssl version
  echo
  composer --version
  echo
  echo "-------------------------------------------------------------------------"
}

install_mariadb()
{
  echo "Install MariaDB"
  sudo apt-get -y install mariadb-server mariadb-client

  echo "Secure MariaDB"
  # `mysql_secure_installation` is interactive so doing the same directly in DB instead...
  # https://gist.github.com/Mins/4602864#gistcomment-1299116
  mysqladmin -u root password "$HW__db__password"
  mysql -u$HW__db__username -p"$HW__db__password" -e "UPDATE mysql.user SET Password=PASSWORD('$HW__db__password') WHERE User='root'"
  mysql -u$HW__db__username -p"$HW__db__password" -e "DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1')"
  mysql -u$HW__db__username -p"$HW__db__password" -e "DELETE FROM mysql.user WHERE User=''"
  mysql -u$HW__db__username -p"$HW__db__password" -e "DELETE FROM mysql.db WHERE Db='test' OR Db='test\_%'"
  mysql -u$HW__db__username -p"$HW__db__password" -e "FLUSH PRIVILEGES"

  echo
  echo "-------------------------------------------------------------------------"
}

install_apache()
{
  echo "Install Apache"
  sudo apt-get -y install apache2

  echo "Enable SSL support in Apache"
  sudo a2enmod ssl
  # sudo a2ensite default-ssl

  echo "Enable Mod Rewrite in Apache"
  sudo a2enmod rewrite

  echo "Allowing Apache override to all"
  sudo sed -i "s/AllowOverride None/AllowOverride All/g" /etc/apache2/apache2.conf

  echo "Restart Apache"
  sudo service apache2 restart

  echo
  echo "-------------------------------------------------------------------------"
}

install_php()
{
  echo "Install PHP and extensions"
  sudo apt-get -y install \
    php7.0 \
    libapache2-mod-php7.0 \
    php7.0-mysql \
    php7.0-curl \
    php7.0-gd \
    php7.0-intl \
    php-pear \
    php-imagick \
    php7.0-imap \
    php7.0-mcrypt \
    php-memcache \
    php7.0-pspell \
    php7.0-recode \
    php7.0-sqlite3 \
    php7.0-tidy \
    php7.0-xmlrpc \
    php7.0-xsl \
    php7.0-mbstring \
    php-gettext;

  echo "Install Opcache and APCu"
  sudo apt-get -y install php7.0-opcache php-apcu

  echo -e "Turn on PHP errors"
  sudo sed -i "s/error_reporting = .*/error_reporting = E_ALL/" /etc/php/7.0/apache2/php.ini
  sudo sed -i "s/display_errors = .*/display_errors = On/" /etc/php/7.0/apache2/php.ini

  echo "Restart Apache"
  sudo service apache2 restart

  echo
  echo "-------------------------------------------------------------------------"
}

install_phpmyadmin()
{
  echo "Install PHPMyAdmin"
  sudo apt-get -y install phpmyadmin
  echo
  echo "-------------------------------------------------------------------------"
}

install_nodejs()
{
  echo "Install NodeJS"
  # https://nodejs.org/en/download/package-manager/#debian-and-ubuntu-based-linux-distributions
  curl -sL https://deb.nodesource.com/setup_6.x | sudo -E bash -
  sudo apt-get install -y nodejs
  echo
  echo "-------------------------------------------------------------------------"
}

install_mail_support()
{
  echo "Install PEAR mail, Net_SMTP, Auth_SASL and mail_mime..."
  sudo pear install mail
  sudo pear install Net_SMTP
  sudo pear install Auth_SASL
  sudo pear install mail_mime

  echo "Install Maildev for catching emails while developing"
  # https://github.com/djfarrelly/MailDev
  npm install -g maildev

  echo "Setup Maildev to start on reboot"
  # Automatically run maildev on start
  sudo cp scripts/init_maildev.sh /etc/init.d/maildev
  sudo chmod 755 /etc/init.d/maildev
  ln -s /etc/init.d/maildev /etc/rc3.d/S99maildev

  echo "Start Maildev"
  sudo sh /etc/init.d/maildev
  echo
  echo "-------------------------------------------------------------------------"

}

install_self_signed_ssl()
{
  # Install self signed SSL certificate if command line flag `--ssl` is set
  # Remember to set `protocol` setting to `https` from `configs/settings.ini`
  if [[ $* == *--ssl* ]]; then
    echo
    echo "Setup self signed SSL certificate..."
    cd "$ROOTDIR"
    bash "$SCRIPTDIR/cert_selfsigned.sh"
  else
    echo
    echo "Skipped installing self signed SSL certificate. "
  fi
  echo
  echo "-------------------------------------------------------------------------"
}

install_bower()
{
  echo
  echo "Install Bower"
  npm install -g bower
  echo
  echo "-------------------------------------------------------------------------"
}

install_composer()
{
  echo
  echo "Install Composer"
  curl --silent https://getcomposer.org/installer
  mv composer.phar /usr/local/bin/composer
  echo
  echo "-------------------------------------------------------------------------"
}

install_mediawiki()
{
  echo
  echo "Download MediaWiki using Composer..."
  cd "$ROOTDIR"
  composer install --no-autoloader --no-dev --no-progress --no-interaction
  echo
  echo "-------------------------------------------------------------------------"


  echo
  echo "Create cache directories..."
  mkdir -p "$WIKIDIR/cache"
  mkdir -p "$WIKIDIR/images/cache"
  echo
  echo "-------------------------------------------------------------------------"


  echo
  echo "Ensure correct permissions for cache folders..."
  set_permissions
  echo
  echo "-------------------------------------------------------------------------"


  echo
  echo "Download basic MediaWiki extensions using Composer..."
  cd "$WIKIDIR"
  cp "$CONFDIR/composer.local.json" .
  composer update --no-dev --no-progress --no-interaction
  echo
  echo "-------------------------------------------------------------------------"


  # Run some post-install scripts for a few extensions
  # These are not run automatically so we'll just manually invoke them.
  # https://github.com/composer/composer/issues/1193
  cd "$WIKIDIR"
  echo
  echo "Run post-install-cmd for HWMap extension..."
  composer run-script post-install-cmd -d ./extensions/HWMap
  solve_mw_maps_extension_bug
  echo
  echo "Run post-install-cmd for HitchwikiVector extension..."
  composer run-script post-install-cmd -d ./extensions/HitchwikiVector
  echo
  echo "Run post-install-cmd for HWRatings extension..."
  composer run-script post-install-cmd -d ./extensions/HWRatings
  echo
  echo "Run post-install-cmd for HWLocationInput extension..."
  composer run-script post-install-cmd -d ./extensions/HWLocationInput
  echo
  echo "-------------------------------------------------------------------------"
}

install_mw_visual_editor(){


  # Install VisualEditor
  # Since it requires submodules, we don't install this using composer
  # https://www.mediawiki.org/wiki/Extension:VisualEditor
  if [[ $* == *--visualeditor* ]]; then # optional command line flag that includes VisualEditor/Parsoid installation
    echo
    echo "Install VisualEditor extension..."
    cd "$WIKIDIR/extensions"
    git clone \
    --branch $HW__general__mw_branch \
    --single-branch \
    --depth=1 \
    --recurse-submodules \
    --quiet \
    https://github.com/wikimedia/mediawiki-extensions-VisualEditor.git \
    VisualEditor;
  else
    echo
    echo "Skipped Installing VisualEditor extension."
  fi
  echo
  echo "-------------------------------------------------------------------------"

}

solve_mw_maps_extension_bug(){
  # Stop Maps extension from setting up a {{#coordinates}} parser function hook
  # that conflicts with GeoData extensions's {{#coordinates}} parser function hook
  #
  # We are using GeoData's function in templates to index articles with spatial info
  #
  # TODO: any solution that is cleaner than this temporary dirty hack..
  echo
  echo "Stop Maps extension from setting up a {{#coordinates}} parser function hook..."
  sed -i -e '111i\ \ /*' -e '116i\ \ */' "$WIKIDIR/extensions/Maps/Maps.php" # wrap damaging lines of code as a /* comment */
  sed -i -e '112i\ \ // This code block has been commented out by Hitchwiki install script. See scripts/server_install.sh for details\n' "$WIKIDIR/extensions/Maps/Maps.php"
  echo
  echo "-------------------------------------------------------------------------"
}

create_db(){
  # Prepare databases
  echo
  echo "Prepare databases..."
  mysql -u$HW__db__username -p$HW__db__password -e "DROP DATABASE IF EXISTS $HW__db__database"
  mysql -u$HW__db__username -p$HW__db__password -e "CREATE DATABASE $HW__db__database CHARACTER SET utf8 COLLATE utf8_general_ci"
  #IFS=$'\n' languages=($(echo "SHOW DATABASES;" | mysql -u$username -p$password | grep -E '^hitchwiki_..$' | sed 's/^hitchwiki_//g'))
  echo
  echo "-------------------------------------------------------------------------"
}

# Install APC
# TODO: https://www.digitalocean.com/community/questions/how-to-install-alternative-php-cache-apc-on-ubuntu-14-04
#echo
#echo "Install APC..."
#sudo apt-get -y install php-apc
#echo
#echo "Restart Apache..."
#sudo /etc/init.d/apache2 restart

pre_setup_mediawiki()
{
  # Setup MediaWiki
  echo
  echo "Running Mediawiki setup script..."
  # Usage: php install.php [--conf|--confpath|--dbname|--dbpass|--dbpassfile|--dbpath|--dbport|--dbprefix|--dbschema|--dbserver|--dbtype|--dbuser|--env-checks|--globals|--help|--installdbpass|--installdbuser|--lang|--memory-limit|--pass|--passfile|--profiler|--quiet|--scriptpath|--server|--wiki] [name] <admin>
  cd "$WIKIDIR"
  # Runs Mediawiki install script:
  # - sets up wiki in one language ("en")
  # - creates one admin user "hitchwiki" with password "authobahn"
  php maintenance/install.php --conf "$MWCONFFILE" \
  --dbuser $HW__db__username \
  --dbpass $HW__db__password \
  --dbname $HW__db__database \
  --dbtype mysql \
  --pass autobahn \
  --scriptpath /$WIKIFOLDER \
  --lang en \
  "$HW__general__sitename" \
  hitchwiki

  echo "php maintenance/install.php --conf "$MWCONFFILE" \
  --dbuser $HW__db__username \
  --dbpass $HW__db__password \
  --dbname $HW__db__database \
  --dbtype mysql \
  --pass autobahn \
  --scriptpath /$WIKIFOLDER \
  --lang en \
  "$HW__general__sitename" \
  hitchwiki"
  echo
  echo "-------------------------------------------------------------------------"
}

setup_mediawiki()
{

  # Config file is stored elsewhere, require it from MW's LocalSettings.php
  echo
  echo "Point Mediawiki configuration to Hitchwiki configuration file..."
  cp -f "$SCRIPTDIR/configs/mediawiki_LocalSettings.php" "$WIKIDIR/LocalSettings.php"
  echo
  echo "-------------------------------------------------------------------------"


  echo
  echo "Setup database for several extensions (SemanticMediaWiki, AntiSpoof etc)..."
  # Mediawiki config file has a check for `SemanticMediaWikiEnabled` file:
  # basically SMW extensions are not included in MediaWiki before this
  # file exists, because it would cause errors when running
  # `maintenance/install.php`.
  touch "$WIKIDIR/extensions/SemanticMediaWikiEnabled"
  cd "$WIKIDIR"
  php maintenance/update.php --quick --conf "$MWCONFFILE"
  echo
  echo "-------------------------------------------------------------------------"


  echo
  echo "Pre-populate the AntiSpoof extension's table..."
  cd "$WIKIDIR"
  php extensions/AntiSpoof/maintenance/batchAntiSpoof.php
  echo
  echo "-------------------------------------------------------------------------"


  # Create bot users
  echo
  echo "Create users"
  cd "$ROOTDIR"
  bash "$SCRIPTDIR/create_users.sh"
  echo
  echo "-------------------------------------------------------------------------"


  # Import Semantic pages, main navigation etc
  echo
  echo "Import Semantic templates and other MediaWiki special pages..."
  cd "$ROOTDIR"
  bash "$SCRIPTDIR/import_pages.sh"
  echo
  echo "-------------------------------------------------------------------------"


  # Import interwiki table
  # https://www.mediawiki.org/wiki/Extension:Interwiki
  echo
  echo "Import interwiki table..."
  cd "$ROOTDIR"
  bash "$SCRIPTDIR/import_interwiki.sh"
  echo
  echo "-------------------------------------------------------------------------"
}

install_parsoid()
{
  # Install Parsoid
  # Parsoid is a Node application required by VisualEditor extension
  # https://www.mediawiki.org/wiki/Parsoid/Setup
  if [[ ! $* == *--no-visualeditor* ]]; then # optional command line flag that excludes VisualEditor/Parsoid from installation
    echo
    echo "Call Parsoid install script..."
    cd "$ROOTDIR"
    bash "$SCRIPTDIR/install_parsoid.sh"
  else
    echo
    echo "Skipped calling Parsoid install script."
  fi
}

set_permissions()
{
  owners="${HW__general__webserver_user}:${HW__general__webserver_group}"

  chown -R $owners "$ROOTDIR"
  chmod -R g+rw "$ROOTDIR"

  chown -R $owners "$WIKIDIR/images"
  chmod -R ug+rw "$WIKIDIR/images"

  chown -R $owners "$WIKIDIR/cache"
  chmod -R ug+rw "$WIKIDIR/cache"
}
