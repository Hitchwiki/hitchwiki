SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET time_zone = "+00:00";

--
-- Table structure for table `interwiki`
-- Read more: https://www.mediawiki.org/wiki/Manual:Interwiki
--

DROP TABLE IF EXISTS `interwiki`;
CREATE TABLE IF NOT EXISTS `interwiki` (
  `iw_prefix` varbinary(32) NOT NULL,
  `iw_url` blob NOT NULL,
  `iw_api` blob NOT NULL,
  `iw_wikiid` varbinary(64) NOT NULL,
  `iw_local` tinyint(1) NOT NULL,
  `iw_trans` tinyint(4) NOT NULL DEFAULT '0'
) ENGINE=InnoDB DEFAULT CHARSET=binary;

--
-- Dumping data for table `interwiki`
--

INSERT INTO `interwiki` (`iw_prefix`, `iw_url`, `iw_api`, `iw_wikiid`, `iw_local`, `iw_trans`) VALUES
('bewelcome', 'https://www.bewelcome.org/$1', '', '', 0, 0),
('bewelcome-location', 'https://www.bewelcome.org/search/members/text?search-can-host=1&search-distance=25&search-location=$1', '', '', 0, 0),
('bg', 'https://hitchwiki.org/bg/$1', '', '', 1, 0),
('bw', 'https://www.bewelcome.org/$1', '', '', 0, 0),
('commons', 'https://commons.wikimedia.org/wiki/$1', '', '', 0, 0),
('couch', 'http://couchwiki.org/en/$1', '', '', 0, 0),
('de', 'https://hitchwiki.org/de/$1', '', '', 1, 0),
('digi', 'http://digihitch.com/$1', '', '', 0, 0),
('en', 'https://hitchwiki.org/en/$1', '', '', 1, 0),
('es', 'https://hitchwiki.org/es/$1', '', '', 1, 0),
('fi', 'https://hitchwiki.org/fi/$1', '', '', 1, 0),
('fr', 'https://hitchwiki.org/fr/$1', '', '', 1, 0),
('he', 'https://hitchwiki.org/he/$1', '', '', 1, 0),
('hr', 'https://hitchwiki.org/hr/$1', '', '', 1, 0),
('it', 'https://hitchwiki.org/it/$1', '', '', 1, 0),
('lt', 'https://hitchwiki.org/lt/$1', '', '', 1, 0),
('maps', 'https://hitchwiki.org/en/Special:HWMap?location=$1', '', '', 1, 0),
('mapslatlon', 'https://hitchwiki.org/en/Special:HWMap?latlon=$1', '', '', 1, 0),
('moneyless', 'http://moneyless.org/$1', '', '', 0, 0),
('nl', 'https://hitchwiki.org/nl/$1', '', '', 1, 0),
('nomad', 'http://nomadwiki.org/en/$1', '', '', 0, 0),
('pl', 'https://hitchwiki.org/pl/$1', '', '', 1, 0),
('pt', 'https://hitchwiki.org/pt/$1', '', '', 1, 0),
('ro', 'https://hitchwiki.org/ro/$1', '', '', 1, 0),
('ru', 'https://hitchwiki.org/ru/$1', '', '', 1, 0),
('share', 'http://sharewiki.org/en/$1', '', '', 0, 0),
('tr', 'https://hitchwiki.org/tr/$1', '', '', 1, 0),
('trash', 'http://trashwiki.org/en/$1', '', '', 0, 0),
('trustroots', 'https://www.trustroots.org/search?location=$1', '', '', 0, 0),
('uk', 'https://hitchwiki.org/uk/$1', '', '', 1, 0),
('wikihow', 'https://www.wikihow.com/$1', '', '', 0, 0),
('wikipedia', 'https://en.wikipedia.org/wiki/$1', '', '', 0, 0),
('wikitravel', 'https://en.wikivoyage.org/wiki/$1', '', '', 0, 0),
('wikivoyage', 'https://en.wikivoyage.org/wiki/$1', '', '', 0, 0),
('zh', 'https://hitchwiki.org/zh/$1', '', '', 1, 0);

--
-- Indexes for table `interwiki`
--
ALTER TABLE `interwiki`
  ADD UNIQUE KEY `iw_prefix` (`iw_prefix`);
