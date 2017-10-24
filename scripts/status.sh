host=127.0.0.1
protocol=http

if [[ $1 ]]; then host=$1; fi
if [[ $2 ]]; then protocol=$2 ; fi
url="$protocol://$host"

declare -A services
services=([apache]="$url Mediawiki" [parsoid]="$url:8142 Parsoid" [maildev]="$url:1080 MailDev" [myadmin]="$url/phpmyadmin phpMyAdmin")

ping=$(ping $host -c1|grep "64 bytes from"|wc -l)
if [[ $ping -gt 0 ]]
then
  echo "$url is online!"
else
  echo "$url seems offline."
  exit
fi

function test {
  url=$1
  name=$2
  html=$(wget -q $url -O -)
  lines=$(echo $html|grep -i $name|wc -l)
  result=?
  if [[ $lines -gt 0 ]]; then result=up; else
    if [[ -z $html ]] ; then result=down; fi; fi
  echo -e "$name: $result - $url"
} 

for service in ${!services[@]}; do
  test ${services[$service]}
done

if [[ ! $1 ]] ; then echo "(Get info on other hosts: $(basename $0) ip|hostname http|https)"; fi
