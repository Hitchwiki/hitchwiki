# HitchWiki Migration bot

Annotates place (country, city, road, etc.) articles with with geographical data.

## Installation

_cd_ into this folder and run:
```
sudo apt-get install python-pip python-dev libmysqlclient-dev
sudo pip install MySQL-python requests httplib2
git clone https://github.com/hitchwiki/hitchwiki-migrate-cache.git .cache
git clone https://github.com/wikimedia/pywikibot-core.git
cd pywikibot-core
git submodule update --init
cd ..
```
## Usage
_cd_ into this folder and run:

```
python pywikibot-core/pwb.py migrate.py
```
