#!/bin/bash

# Hitchwiki basic users creation script. Useful if the dataase got drooooped.

# Paths
ROOTDIR="/var/www"
CONFDIR="$ROOTDIR/configs"
CONFPATH="$CONFDIR/mediawiki.php"
SCRIPTDIR="$ROOTDIR/scripts"
WIKIFOLDER="wiki"
WIKIDIR="$ROOTDIR/public/$WIKIFOLDER"

# Makes sure we have settings.ini and "Bash ini parser"
source "$SCRIPTDIR/_settings.sh"

cd "$WIKIDIR"


# Create hitchwiki account
echo ""
echo "Create hitchwiki account..."
php maintenance/createAndPromote.php --bureaucrat --sysop --bot --force Hitchwiki autobahn

# Create bot account
echo ""
echo "Create bot account..."
php maintenance/createAndPromote.php --bureaucrat --sysop --bot --force Hitchbot autobahn

# Create another dummy account
echo "Create another dummy account..."
php maintenance/createAndPromote.php Hitchhiker autobahn

# Confirm emails for all created users
echo ""
echo "Confirm emails for all created users..."
mysql -u$HW__db__username -p$HW__db__password $HW__db__database -e "UPDATE user SET user_email = 'hitchwiki@localhost',  user_email_authenticated = '20141218000000' WHERE user_name = 'Hitchwiki'"
mysql -u$HW__db__username -p$HW__db__password $HW__db__database -e "UPDATE user SET user_email = 'hitchbot@localhost',   user_email_authenticated = '20141218000000' WHERE user_name = 'Hitchbot'"
mysql -u$HW__db__username -p$HW__db__password $HW__db__database -e "UPDATE user SET user_email = 'hitchhiker@localhost', user_email_authenticated = '20141218000000' WHERE user_name = 'Hitchhiker'"