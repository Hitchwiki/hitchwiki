-- Generation Time: Jan 19, 2015 at 10:14 AM

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET time_zone = "+00:00";

--
-- Table structure for table `interwiki`
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
('bg', 'http://hitchwiki.org/bg/$1', '', '', 1, 0),
('bw', 'http://www.bewelcome.org/$1', '', '', 0, 0),
('commons', 'http://commons.wikimedia.org/wiki/$1', '', '', 0, 0),
('couch', 'http://couchwiki.org/en/$1', '', '', 0, 0),
('de', 'http://hitchwiki.org/de/$1', '', '', 1, 0),
('digi', 'http://digihitch.com/$1', '', '', 0, 0),
('en', 'http://hitchwiki.org/en/$1', '', '', 1, 0),
('es', 'http://hitchwiki.org/es/$1', '', '', 1, 0),
('fi', 'http://hitchwiki.org/fi/$1', '', '', 1, 0),
('fr', 'http://hitchwiki.org/fr/$1', '', '', 1, 0),
('he', 'http://hitchwiki.org/he/$1', '', '', 1, 0),
('hitchingit', 'http://www.hitching.it/$1', '', '', 0, 0),
('hr', 'http://hitchwiki.org/hr/$1', '', '', 1, 0),
('it', 'http://hitchwiki.org/it/$1', '', '', 1, 0),
('lt', 'http://hitchwiki.org/lt/$1', '', '', 1, 0),
('maps', 'http://hitchwiki.org/en/Special:HWMap?location=$1', '', '', 1, 0),
('moneyless', 'http://moneyless.org/$1', '', '', 0, 0),
('nl', 'http://hitchwiki.org/nl/$1', '', '', 1, 0),
('nomad', 'http://nomadwiki.org/en/$1', '', '', 0, 0),
('pl', 'http://hitchwiki.org/pl/$1', '', '', 1, 0),
('pt', 'http://hitchwiki.org/pt/$1', '', '', 1, 0),
('ro', 'http://hitchwiki.org/ro/$1', '', '', 1, 0),
('ru', 'http://hitchwiki.org/ru/$1', '', '', 1, 0),
('share', 'http://sharewiki.org/en/$1', '', '', 0, 0),
('tr', 'http://hitchwiki.org/tr/$1', '', '', 1, 0),
('trash', 'http://trashwiki.org/en/$1', '', '', 0, 0),
('trustroots', 'https://www.trustroots.org/#!/search?location=$1', '', '', 0, 0),
('wikihow', 'http://www.wikihow.com/$1', '', '', 0, 0),
('wikipedia', 'https://en.wikipedia.org/wiki/$1', '', '', 0, 0),
('wikitravel', 'http://en.wikivoyage.org/wiki/$1', '', '', 0, 0),
('wikivoyage', 'https://en.wikivoyage.org/wiki/$1', '', '', 0, 0),
('zh', 'http://hitchwiki.org/zh/$1', '', '', 1, 0);

--
-- Indexes for dumped tables
--

--
-- Indexes for table `interwiki`
--
ALTER TABLE `interwiki`
  ADD UNIQUE KEY `iw_prefix` (`iw_prefix`);
