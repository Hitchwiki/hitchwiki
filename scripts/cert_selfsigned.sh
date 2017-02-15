#!/bin/bash

# Creates self signed SSL certificate for development purposes
# https://www.digitalocean.com/community/tutorials/how-to-create-a-self-signed-ssl-certificate-for-apache-in-ubuntu-16-04

if [ ! -f Vagrantfile ]; then # an arbirtrary file that appears only once in the whole repository tree
    echo "ERROR: Bad working directory ($(pwd))."
    echo "Scripts have to be run from the root directory of the hitchwiki repository."
    echo "Aborting."
    exit 1
fi

# Fixes possible "warning: Setting locale failed." errors
export LC_ALL="en_US.UTF-8"
export LANGUAGE="en_US.UTF-8"

# Paths
source "scripts/_path_resolve.sh"

# Makes sure we have settings.ini and "Bash ini parser"
source "$SCRIPTDIR/_settings.sh"

echo ""
echo "Create the SSL Certificate..."
sudo openssl req -subj "/CN=$HW__general__domain/O=$HW__general_sitename/C=DE" -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/ssl/private/apache-selfsigned.key -out /etc/ssl/certs/apache-selfsigned.crt

echo ""
echo "Generate a Diffie-Hellman group..."
sudo openssl dhparam -out /etc/ssl/certs/dhparam.pem 2048 > /dev/null 2>&1

echo ""
echo "Create SSL configuration for Apache..."
echo "File: /etc/apache2/conf-available/ssl-params.conf"
# Using temporary file `$ROOTDIR/tmp/ssl-params.conf` because
#  output redirection (`>>`) is done by the shell, not by `cat`,
#  and thus `sudo` won't work.
#
# http://askubuntu.com/a/230482
cd "$ROOTDIR"
mkdir tmp
cd tmp
sudo cat <<EOT >> ssl-params.conf
# from https://cipherli.st/
# and https://raymii.org/s/tutorials/Strong_SSL_Security_On_Apache2.html

SSLCipherSuite EECDH+AESGCM:EDH+AESGCM:AES256+EECDH:AES256+EDH
SSLProtocol All -SSLv2 -SSLv3
SSLHonorCipherOrder On
# Disable preloading HSTS for now.  You can use the commented out header line that includes
# the "preload" directive if you understand the implications.
#Header always set Strict-Transport-Security "max-age=63072000; includeSubdomains; preload"
Header always set Strict-Transport-Security "max-age=63072000; includeSubdomains"
Header always set X-Frame-Options DENY
Header always set X-Content-Type-Options nosniff
# Requires Apache >= 2.4
SSLCompression off
SSLSessionTickets Off
SSLUseStapling on
SSLStaplingCache "shmcb:logs/stapling-cache(150000)"


SSLProtocol ALL -SSLv2 -SSLv3
SSLHonorCipherOrder On
SSLCipherSuite ECDH+AESGCM:DH+AESGCM:ECDH+AES256:DH+AES256:ECDH+AES128:DH+AES:RSA+AESGCM:RSA+AES:!aNULL:!MD5:!DSS


## For Newer Apache+OpenSSL:

## If you have Apache 2.4.8 or later and OpenSSL 1.0.2 or later, you can
## generate and specify your DH params file:
## https://raymii.org/s/tutorials/Strong_SSL_Security_On_Apache2.html#Forward_Secrecy_&_Diffie_Hellman_Ephemeral_Parameters
## https://httpd.apache.org/docs/trunk/mod/mod_ssl.html#sslopensslconfcmd
#SSLOpenSSLConfCmd DHParameters "/etc/ssl/certs/dhparam.pem"

## OR for older Apache+OpenSSL:

## From http://serverfault.com/a/693244
## On Debian Wheezy upgrade apache2 to 2.2.22-13+deb7u4 or later and openssl
## to 1.0.1e-2+deb7u17. The above SSLCipherSuite does not work perfectly,
## instead use the following as per this blog:
## https://blog.cscholz.io/debian-wheezy-apache-logjam/10492/
SSLCipherSuite ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-AES256-GCM-SHA384:DHE-DSS-AES128-GCM-SHA256:kEDH+AESGCM:ECDHE-RSA-AES128-SHA256:ECDHE-ECDSA-AES128-SHA256:ECDHE-RSA-AES128-SHA:ECDHE-ECDSA-AES128-SHA:ECDHE-RSA-AES256-SHA384:ECDHE-ECDSA-AES256-SHA384:ECDHE-RSA-AES256-SHA:ECDHE-ECDSA-AES256-SHA:DHE-DSS-AES128-SHA256:DHE-DSS-AES256-SHA:AES128-GCM-SHA256:AES256-GCM-SHA384:AES128-SHA:AES256-SHA:AES:CAMELLIA:DES-CBC3-SHA:!aNULL:!eNULL:!EXPORT:!DES:!RC4:!MD5:!PSK:!aECDH:!EDH-DSS-DES-CBC3-SHA:!EDH-RSA-DES-CBC3-SHA:!KRB5-DES-CBC3-SHA:!DHE-RSA-AES128-GCM-SHA256:!DHE-RSA-AES256-GCM-SHA384:!DHE-RSA-AES128-SHA256:!DHE-RSA-AES256-SHA:!DHE-RSA-AES128-SHA:!DHE-RSA-AES256-SHA256:!DHE-RSA-CAMELLIA128-SHA:!DHE-RSA-CAMELLIA256-SHA

EOT
sudo mv "$ROOTDIR/tmp/ssl-params.conf" /etc/apache2/conf-available/ssl-params.conf
cd "$ROOTDIR"
sudo rm -fr "$ROOTDIR/tmp/"


echo ""
echo "Modify default SSL VirtualHost configuration file for Apache..."
echo "File: /etc/apache2/sites-available/default-ssl.conf"
# Using temporary file `$ROOTDIR/tmp/default-ssl.conf` because
#  output redirection (`>>`) is done by the shell, not by `cat`,
#  and thus `sudo` won't work.
#
# http://askubuntu.com/a/230482
cd "$ROOTDIR"
mkdir tmp
cd tmp
sudo cat <<EOT > default-ssl.conf
<IfModule mod_ssl.c>
        <VirtualHost _default_:443>
                ServerAdmin webmaster@localhost
                ServerName $HW__general__domain

                DocumentRoot $ROOTDIR/public

                ErrorLog \${APACHE_LOG_DIR}/error.log
                CustomLog \${APACHE_LOG_DIR}/access.log combined

                SSLEngine on

                SSLCertificateFile      /etc/ssl/certs/apache-selfsigned.crt
                SSLCertificateKeyFile   /etc/ssl/private/apache-selfsigned.key

                <FilesMatch "\.(cgi|shtml|phtml|php)$">
                                SSLOptions +StdEnvVars
                </FilesMatch>
                <Directory /usr/lib/cgi-bin>
                                SSLOptions +StdEnvVars
                </Directory>

                BrowserMatch "MSIE [2-6]" \
                                nokeepalive ssl-unclean-shutdown \
                                downgrade-1.0 force-response-1.0
                # MSIE 7 and newer should be able to use keepalive
                BrowserMatch "MSIE [17-9]" ssl-unclean-shutdown
        </VirtualHost>
</IfModule>

# vim: syntax=apache ts=4 sw=4 sts=4 sr noet
EOT
sudo mv "$ROOTDIR/tmp/default-ssl.conf" /etc/apache2/sites-available/default-ssl.conf
cd "$ROOTDIR"
sudo rm -fr "$ROOTDIR/tmp/"

echo ""
echo "Enable ssl and headers modules for Apache..."
sudo a2enmod ssl
sudo a2enmod headers

echo ""
echo "Enable SSL Virtual Host..."
sudo a2ensite default-ssl

echo ""
echo "Enable ssl-params.conf file..."
sudo a2enconf ssl-params

echo ""
echo "Apache config test:"
sudo apache2ctl configtest

echo ""
echo "Restart Apache..."
sudo service apache2 restart
