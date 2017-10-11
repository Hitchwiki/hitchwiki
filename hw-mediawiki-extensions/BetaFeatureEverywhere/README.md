# BetaFeatureEverywhere extension for MediaWiki

Force MediaWiki [BetaFeatures](https://www.mediawiki.org/wiki/Extension:BetaFeatures) on/off for everyone, everywhere & everytime.

By [Mikael Korpela](http://www.mikaelkorpela.fi).

# Install

First install [BetaFeatures](https://www.mediawiki.org/wiki/Extension:BetaFeatures)

Clone this extension under `extensions`:
```bash
git clone https://github.com/simison/BetaFeatureEverywhere.git
```
...or [download the zip file](https://github.com/simison/BetaFeatureEverywhere/archive/master.zip).

Add to LocalSettings.php
```php
require_once "$IP/extensions/BetaFeatureEverywhere/BetaFeatureEverywhere.php";
```

Turn features on or off using `$wgDefaultUserOptions` variable at `LocalSettings.php`:
```php
$wgDefaultUserOptions['betafeatures-vector-typography-update'] = '0';
$wgDefaultUserOptions['betafeatures-vector-fixedheader'] = '1';
```
Set value to 1 to feature on and 0 off.

Extension also hides setting this feature from preferences.

If you don't list feature here, it will work just normally (as opt-in).

For [VectorBeta](https://www.mediawiki.org/wiki/Extension:VectorBeta) you must also enable features first using `$wgVectorBetaTypography`, `$wgVectorBetaPersonalBar` and `$wgVectorBetaWinter` flags (set them `true`).

### Supported feature flags

* [betafeatures-vector-compact-personal-bar](https://www.mediawiki.org/wiki/Compact_Personal_Bar)
* [betafeatures-vector-typography-update](https://www.mediawiki.org/wiki/Typography_refresh)
* [betafeatures-vector-fixedheader](https://www.mediawiki.org/wiki/Winter)
* [visualeditor-enable](https://www.mediawiki.org/wiki/VisualEditor)
* [popups](https://www.mediawiki.org/wiki/Extension:Popups)

You can extend this list by offering an array of features at `LocalSettings.php`:

```php
$wgBetaFeaturesEverywhere = array('betafeatures-my-own');
```

# License
MIT
