#!/bin/bash
services="monit apache2 mysql parsoid"
if [ $(whoami) != 'root' ]; then echo "I need more rights! (give me names and I make it stop, else: $services)"; exit 1; fi
if [ $1 ]; then services="$@" ; fi
echo "Database backup"
backupninja
for service in $services; do
  echo "Stopping $service"
  service $service stop
  ps ax|grep $service
done
apache2ctl stop
ps ax|grep apache2
