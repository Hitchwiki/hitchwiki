if [[ $(whoami) != 'root' ]] ; then
  echo "Please run this as root."
  exit
fi
for log in apache-access.log apache-error.log auth.log letsencrypt.log parsoid.log fail2ban.log monit.log syslog unattended-upgrades.log unattended-upgrades-dpkg.log
do
  tail -f logs/$log &
done
