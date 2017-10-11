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

## How to help
This version is currently under heavy development in Vilnius, 5.—16.12.2016 by [@simison](https://github.com/simison), [@Remigr](https://github.com/Remigr/) and [@omelnyk](https://github.com/omelnyk/).

_[Contact us](http://hitchwiki.org/en/Template:Communityportal) if you want to join the effort!_

Read more about developing Hitchwiki [from the wiki](https://github.com/Hitchwiki/hitchwiki/wiki)

## Installing

We have two major ways of running the software:


### Installing locally

Install the stack on your localhost. This approach takes a little more time to setup, and bit more manual configuration, but is super fast, and can be easier to work with. See [INSTALL.md](https://raw.githubusercontent.com/Hitchwiki/hitchwiki/master/INSTALL.md) for details.

### Installing with Vagrant

The easiest and quickest way to get started is with Vagrant. Running through Vagrant can be a little bit slower. See [INSTALL-vagrant.md](https://raw.githubusercontent.com/Hitchwiki/hitchwiki/master/INSTALL-vagrant.md) for further details.

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
