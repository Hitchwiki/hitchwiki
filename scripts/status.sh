declare -A services
ping=$(ping hitchwiki.test -c1|grep "64 bytes from"|wc -l)
services[apache]=$(wget -q http://hitchwiki.test -O - |grep mediawiki|wc -l)
services[parsoid]=$(wget -q http://hitchwiki.test:8142 -O -|grep "Parsoid</a> web service"|wc -l)
services[maildev]=$(wget -q http://hitchwiki.test:1080 -O -|grep "MailDev"|wc -l)
services[phpmyadmin]=$(wget -q http://hitchwiki.test/phpmyadmin -O -|grep "phpMyAdmin"|wc -l)

if [[ $ping -gt 0 ]] ; then echo "Machine is up."; else echo "Machine is down."; exit; fi
for service in ${!services[@]}; do
  if [[ ${services[$service]} -gt 0 ]]; then echo "$service is up."; else echo "$service is down." ; fi
done
