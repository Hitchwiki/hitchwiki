#!/bin/bash
services="monit apache2 mysqld parsoid"
if [ $(whoami) != 'root' ]; then echo "I need more rights! (give me names and I make it stop, else: $services)"; exit 1; fi
if [ $1 ]; then services="$@" ; fi
set -e
echo "Database backup"
backupninja
#echo "Drop databases"
#mysql -uroot -proot hitchwiki_en -e "DROP DATABASE hitchwiki_en" # TODO
for service in $services; do
  bin=$(which $service)
  echo "Stopping $service"
  service $service stop || ([ -f /etc/init.d/$service ] && /etc/init.d/$service stop)
  remaining=$(ps ax|grep $bin|wc -l)
  if [ $remaining -gt 1 ]
  then echo "$service is still running, please stop it manually."; ps ax|grep $bin; exit 1
  fi
done
apache2ctl stop
ps ax|grep apache2
