#!/bin/bash
# This script will the installation status and print variables to `scripts/ansible/.state.yml`
# For details see `scripts/ansible/status.yml`
cd $(dirname $0)/ansible
sf=state.yml

if [[ $(whoami) == 'root' ]] ; then
  [ -d /etc/facts.d ] || mkdir /etc/facts.d
  sf=/etc/facts.d/state.yml
fi
[ -f $sf ] && rm $sf
echo "# Ansible installation report" >> $sf
echo "timestamp: $(date +%s)" >> $sf
echo "date: $(date +%Y-%m-%d)" >> $sf
echo "time: $(date +%H:%M)" >> $sf
url="http://$host"

function test {
  url=$1
  name=$2
  tag=$3
  html=$(wget -q $url -O -)
  lines=$(echo $html|grep -i $tag|wc -l)
  [[ $lines -gt 0 ]] && ${!2}=true
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

# chapters
echo -e "\nstate:" >> $sf
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
[ -d /etc/ansible/facts.d ] && system=true
[ -e /var/run/mysqld/mysqld.sock ] && db=true
[ -e /var/run/apache2/apache2.pid ] && web=true
[ -f /etc/apache2/sites-enabled/default-ssl.conf ] && tls=true
[ -f /etc/letsencrypt/live/beta.hitchwiki.org/fullchain.pem ] && cert=true
[[ -n $monit_bin ]] && [ $(monit status) ] && monit=true
[[ -n $monit_bin ]] && [[ ${1+$monit+$tls+$cert} -gt 3 ]] && production=true
test $url mw Mediawiki
test $url:8142 parsoid Parsoid
test $url:1080 maildev MailDev
test $url/phpmyadmin phpmyadmin phpMyAdmin
[[ ${1+$maildev+$phpmyadmin} -gt 2 ]] && dev=true

for chapter in system db web tls cert mw parsoid monit production maildev phpmyadmin dev
do echo "  $chapter: ${!chapter}" >> $sf
done

# syntax
echo -e "\nsyntax:" >> $sf
apache_syntax=false
monit_syntax=false
[[ -n $apachectl_bin ]] && [[ $($apachectl_bin -t) -ne "Syntax OK" ]] && apache_syntax=true
[[ -n $monit_bin ]] && [[ $($monit_bin -t|grep "Control file syntax OK"|wc -l) -gt 0 ]] && monit_syntax=true
echo "  apache: $apache_syntax" >> $sf
echo "  monit: $monit_syntax" >> $sf

# versions
echo -e "\nversions:" >> $sf
[[ -n $apachectl_bin ]] && apache_ver=$(apache2ctl -V|head -n1)
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
