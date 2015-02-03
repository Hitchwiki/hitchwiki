# Hitchwiki bot collection

[pywikibot]-based toolchain for mass manipulation of Hitchwiki articles and
custom extension data (comments, ratings and waiting times).

Since direct database access is used for modifying custom extension data,
such changes are not reversible through the MediaWiki revision system.
Beware when using in production.

## Installation

_cd_ into this folder and run (inside Vagrant, if using it):
```bash
sudo apt-get install python-pip python-dev libmysqlclient-dev
sudo pip install MySQL-python requests httplib2 ftfy
git clone https://github.com/hitchwiki/hitchwiki-migrate-cache.git .cache
git clone https://github.com/wikimedia/pywikibot-core.git
cd pywikibot-core
git submodule update --init
cd ..
```

## Tool list

_cd_ into this folder before running the chosen command.

```bash
# Annotate place articles with geographical semantic templates
python pywikibot-core/pwb.py locationsemanticize.py
```

```bash
# Turn spots from the old DB into semantic MediaWiki articles
python pywikibot-core/pwb.py spotmigrate.py
```

```bash
# Migrate comments, ratings and waiting times from the old DB into the new DB
python pywikibot-core/pwb.py extramigrate.py
```
