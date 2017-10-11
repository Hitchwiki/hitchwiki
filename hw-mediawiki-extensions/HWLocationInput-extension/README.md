# Hitchwiki Location input
### for Page-Forms extension

Adds new input type ("HW_Location") to handle Hitchwiki locations for [Page Forms](https://www.mediawiki.org/wiki/Extension:Page_Forms) extension.

Internal project extension to use at our wikis ([Hitchwiki](http://hitchwiki.org), [Nomadwiki](http://hitchwiki.org), [Trashwiki](http://trashwiki.org)).

Part of [Hitchwiki.org](https://github.com/Hitchwiki/hitchwiki) MediaWiki setup.

[Contact us](http://hitchwiki.org/contact).

## Install manually

Note that normal Hitchwiki takes care of installing this extension.

Clone under `extensions`:
```bash
git clone https://github.com/Hitchwiki/HWLocationInput-extension.git extensions/HWLocationInput
```

Add to `LocalSettings.php`
```php
wfLoadExtension('HWLocationInput');
```

Make sure you have these defined at `LocalSettings.php`:
```php
$hwGeonamesUsername
$hwMapboxUsername
$hwMapboxAccessToken
$hwMapboxMapkeyStreets
$hwMapboxMapkeySatellite
```

# License
MIT
