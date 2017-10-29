# Hitchwiki bot collection

[pywikibot]-based toolchain for mass manipulation of Hitchwiki articles and
custom extension data (comments, ratings and waiting times).

Since direct database access is used for modifying custom extension data,
such changes are not reversible through the MediaWiki revision system.
Beware when using in production.

## Installation

_cd_ into this folder and run (inside Vagrant, if using it):
```bash
./bot_install.sh
```

Following files from the live hitchwiki.org need to be present in `/dumps/`:
- old-images.tar.gz
- old-hitchwiki.sql
- old-hitchwiki_maps.sql
- old-hitchwiki_rate.sql
- hitchwiki_en.sql
- hitchwiki_maps.sql
- hitchwiki_rate.sql

## Tool list

_cd_ into this folder before running the chosen command.

```bash
# Annotate place articles with geographical semantic templates
python pywikibot-core/pwb.py migrate/articlemigrate.py
```

```bash
# Turn spots from the old DB into semantic MediaWiki articles
python pywikibot-core/pwb.py migrate/spotmigrate.py
```

```bash
# Migrate comments, ratings and waiting times from the old DB into the new DB
python pywikibot-core/pwb.py migrate/extramigrate.py
```
