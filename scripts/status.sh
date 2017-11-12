#!/bin/bash
# This script will the installation status and print variables to `scripts/ansible/.state.yml`
# For details see `scripts/ansible/status.yml`
cd $(dirname $0)/ansible
sf=state.yml
echo "# Ansible status report
status:
  timestamp: $(date +%s)
  creation_date: $(date +%Y-%m-%d)
  creation_time: $(date +%H:%M)" > $sf
url="http://127.0.0.1"

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
[ -f /var/run/maildev.pid ] && maildev=true
[ $(curl -s "$url" |grep -i hitchwiki|wc -l) != 0 ] && apache=true
[ $(curl -s "$url:1080" |grep -i maildev|wc -l) != 0 ] && maildev=true
[ $(curl -s "$url/phpmyadmin" |grep -i phpmyadmin|wc -l) != 0 ] && phpmyadmin=true
[ $(curl -s "$url:8142" |grep -i parsoid|wc -l) != 0 ] && parsoid=true
installation_finished=true
for app in apache mysql parsoid maildev phpmyadmin monit
do echo "  $app: ${!app}" >> $sf
case $chapter in # skip non-mandatory services
  (maildev|phpmyadmin)	continue
esac
[[ $chapter == 'false' ]] && installation_finished=false
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
production=false
maildev=false
phpmyadmin=false
dev=false
discourse=false
[ -f /usr/local/bin/node ] && system=true
[ -d /etc/mysql ] && db=true
[ -e /etc/apache2/sites-enabled/hitchwiki.conf ] && web=true
[ -f /var/www/public/wiki/extensions/SemanticMediaWikiEnabled ] && mw=true
[ -f /etc/mediawiki/parsoid/config.yaml ] && parsoid=true
[ -f /etc/apache2/sites-enabled/default-ssl.conf ] && tls=true
[[ -n $monit_bin ]] && [[ ! $(monit status 2>&1 >/dev/null) ]] && monit=true
[ $monit == "true" ] && [ $tls == "true" ] && production=true
[ -d /usr/share/phpmyadmin/ ] && phpmyadmin=true
[ -f /etc/init.d/maildev ] && maildev=true
[ $phpmyadmin == 'true' ] && [ $maildev == 'true' ] && dev=true
[ -f /etc/init.d/discourse ] || [ -d /var/www/public/discourse/public ] &&  discourse=true
for chapter in system db web tls mw parsoid monit production maildev phpmyadmin dev discourse
do echo "  $chapter: ${!chapter}" >> $sf
case $chapter in # skip non-mandatory chapters
  (tls|production|maildev|phpmyadmin|dev|discourse)	continue
esac
[[ $chapter == 'false' ]] && installation_finished=false
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
function get_version() {
  version=false
  app=$1
  bin=$(which $1)
  if [[ -n $2 ]]
  then
    [[ -n $bin ]] && version="'$($bin --version |head -n1|cut -f$2 -d' ')'"
  else
    [[ -n $bin ]] && version="'$($bin --version |head -n1)'"
  fi
  echo "  $app: $version" >> $sf
}
echo -e "\nversions:" >> $sf
apache_ver=false
openssl_ver=false
[[ -n $apachectl_bin ]] && apache_ver="'$(apache2ctl -V|head -n1|cut -f2 -d'/')'"
[[ -n $openssl_bin ]] && openssl_ver="'$(openssl version|head -n1|cut -f2 -d' ')'"
for app in ansible pip; do get_version $app 2; done
get_version mysql 3
echo "  apache2: $apache_ver" >> $sf
echo "  openssl: $openssl_ver" >> $sf
for app in php npm node bower composer rvm
do get_version $app 1; done

cat $sf
