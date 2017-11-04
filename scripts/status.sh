#!/bin/bash
# This script will the installation status and print variables to `scripts/ansible/.state.yml`
# For details see `scripts/ansible/status.yml`
cd $(dirname $0)/ansible
sf=state.yml

if [[ $(whoami) == 'root' ]] ; then
  [ -d /etc/ansible/facts.d ] || mkdir -p /etc/ansible/facts.d
  sf=/etc/ansible/facts.d/state.yml
  touch $sf
  chmod a+r $sf
fi
[ -f $sf ] && rm $sf
echo "# Ansible installation report" >> $sf
echo "timestamp: $(date +%s)" >> $sf
echo "date: $(date +%Y-%m-%d)" >> $sf
echo "time: $(date +%H:%M)" >> $sf
url="http://127.0.0.1"

function check_url {
  url=$1
  name=$2
  tag=$3
  html=$(wget -q $url -O -)
  lines=$(echo $html|grep -i $tag|wc -l)
  [[ $lines -gt 0 ]] && name=true
  name=false
} 

# binaries
monit_bin=$(which monit)
apache_bin=$(which apache2)
apachectl_bin=$(which apache2ctl)
node_bin=$(which node)
openssl_bin=$(which openssl)
echo -e "\nbin:" >> $sf
echo "  apache: $apache_bin" >> $sf
echo "  mysqld: $(which mysqld)" >> $sf
echo "  certbot: $(which certbot)" >> $sf
echo "  monit: $monit_bin" >> $sf
echo "  backup: $(which backupninja)" >> $sf

echo -e "\nstarted:" >> $sf
apache=false
mysql=false
parsoid=false
maildev=false
phpmyadmin=false
monit=false
[ -e /var/run/mysqld/mysqld.sock ] && mysql=true
[ -f /var/run/apache2/apache2.pid ] && apache=true
[ -f /var/run/parsoid.pid ] && parsoid=true
[ -f /var/run/monit.pid ] && monit=true
check_url $url:1080 maildev MailDev
check_url $url/phpmyadmin phpmyadmin phpMyAdmin
for app in apache mysql parsoid maildev phpmyadmin monit
do echo "  $app: ${!app}" >> $sf
done

# configured
echo -e "\nconfigured:" >> $sf
system=false
db=false
web=false
mw=false
parsoid=false
monit=false
tls=false
cert=false
production=false
maildev=false
phpmyadmin=false
dev=false
[ -f /usr/local/bin/node ] && system=true
[ -d /etc/mysql ] && db=true
[ -e /etc/apache2/sites-enabled/hitchwiki.conf ] && web=true
[ -f /var/www/public/wiki/extensions/SemanticMediaWikiEnabled ] && mw=true
[ -f /etc/mediawiki/parsoid/config.yaml ] && parsoid=true
[ -f /etc/apache2/sites-enabled/default-ssl.conf ] && tls=true
[ -f /etc/letsencrypt/live/beta.hitchwiki.org/fullchain.pem ] && cert=true
[[ -n $monit_bin ]] && [[ ! $(monit status 2>&1 >/dev/null) ]] && monit=true
[ $monit == "true" ] && [ $tls == "true" ] && [ $cert == "true" ] && production=true
[ -f /etc/init.d/maildev ] && maildev=true && dev=true

for chapter in system db web tls cert mw parsoid monit production maildev phpmyadmin dev
do echo "  $chapter: ${!chapter}" >> $sf
done

# syntax
echo -e "\nsyntax:" >> $sf
apache_syntax=false
monit_syntax=false
[[ $(apache2ctl -t 2>&1|grep OK|wc -l) -gt 0 ]] && apache_syntax=true
[[ -n $monit_bin ]] && [[ $($monit_bin -t 2>&1|grep "Control file syntax OK"|wc -l) -gt 0 ]] && monit_syntax=true
echo "  apache: $apache_syntax" >> $sf
echo "  monit: $monit_syntax" >> $sf

# versions
echo -e "\nversions:" >> $sf
[[ -n $apachectl_bin ]] && apache_ver=$(apache2ctl -V|head -n1|cut -f 2 -d':')
[[ -n $openssl_bin ]] && openssl_ver=$(openssl version)
echo "  apache2: $apache_ver" >> $sf
echo "  openssl: openssl_ver" >> $sf
for app in php npm node bower composer
do
  bin=$(which $app)
  [[ -n $bin ]] && version=$($app --version |head -n1)
  echo "  $app: $version" >> $sf
done
cat $sf
