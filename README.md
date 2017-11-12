# Hitchwiki

#### _The Hitchhiker's Guide to Hitchhiking the World_

![Hitchwiki logo](public/wiki-badge.png)

[Hitchwiki.org](http://hitchwiki.org/) is a collaborative website for
gathering information about
[hitchhiking](http://hitchwiki.org/en/Hitchhiking) and other ways of
extremely cheap ways of transport. It is maintained by many active
hitchhikers all around the world. We have information about how to
hitch out of big cities, how to cover long distances, maps and many
more tips.

[![Build Status](https://travis-ci.org/Hitchwiki/hitchwiki.svg?branch=master)](https://travis-ci.org/Hitchwiki/hitchwiki)

## Help needed!
_[Contact us](http://hitchwiki.org/en/Template:Communityportal) if you want to join the effort!_

Read more about developing Hitchwiki [from the wiki](https://github.com/Hitchwiki/hitchwiki/wiki), our [scripts](scripts/README.md) and [ansible](scripts/ansible/README.md).

## Installing

We use ansible to deploy locally or via vagrant, see [INSTALL.md](INSTALL.md) for details.

## License
Code [MIT](LICENSE.md)
Contents [Creative Commons](http://creativecommons.org/licenses/by-sa/4.0/)

## Hitchwiki Mediawiki Extensions
All Hitchwiki functionality is created on top of MediaWiki using extensions under `./hw-mediawiki-extensions`.

These folders are symlinked to Mediawiki by Composer using [path repositories](https://getcomposer.org/doc/05-repositories.md#path).

Previously our custom MediaWiki extension code was hosted at separate repositories:
- [HWMap-extension](https://github.com/Hitchwiki/HWMap-extension)
- [HWRatings-extension](https://github.com/Hitchwiki/HWRatings-extension)
- [HWWaitingTime-extension](https://github.com/Hitchwiki/HWWaitingTime-extension)
- [HWComments-extension](https://github.com/Hitchwiki/HWComments-extension)
- [HWLocationInput-extension](https://github.com/Hitchwiki/HWLocationInput-extension)
- [HitchwikiVector-extension](https://github.com/Hitchwiki/HitchwikiVector-extension)
- [BetaFeatureEverywhere](https://github.com/Hitchwiki/BetaFeatureEverywhere)
- [HWVectorBeta](https://github.com/Hitchwiki/mediawiki-extensions-VectorBeta) (Our fork of an abandoned extension, previously `VectorBeta`)
