#!/bin/bash

#
# Install bot's dependencies
#

WIKIBOTDIR="./"

sudo apt-get install python-pip python-dev libmysqlclient-dev
sudo pip install MySQL-python requests httplib2 ftfy

if cd "$WIKIBOTDIR/.cache"; then
    git stash # preserve fresh cache entries
    git pull
    git stash pop
else
    git clone https://github.com/hitchwiki/hitchwiki-migrate-cache.git .cache
fi

if cd "$WIKIBOTDIR/pywikibot-core"; then
    git pull
else
    git clone https://github.com/wikimedia/pywikibot-core.git pywikibot-core
fi
cd "$WIKIBOTDIR/pywikibot-core"
git submodule update --init
