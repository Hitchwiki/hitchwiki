# HitchWiki Migration bot

Annotates place (country, city, road, etc.) articles with with geographical data.

## Installation

_cd_ into this folder and run:
```
mkdir .cache
git clone https://github.com/hitchwiki/hitchwiki-migrate-cache.git .cache
git clone https://github.com/wikimedia/pywikibot-core.git 
git -C pywikibot-core submodule update --init
```
## Usage
_cd_ into this folder and run:

```
python pywikibot-core/pwb.py migrate.py
```
