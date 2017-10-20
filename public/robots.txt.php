<?php
/* robots.txt
 * http://www.robotstxt.org/
 * https://www.mediawiki.org/wiki/Manual:Robots.txt
 */

header("Content-Type: text/plain");

# $hwConfig = parse_ini_file("../configs/settings.ini", true);
$hwConfig = cat ../configs/settings.ini | shyaml get-value mapping

// Production environment
if(isset($hwConfig['general']['env']) && $hwConfig['general']['env'] == 'prod'):
?>
# No special pages (edit pages, diff pages, etc)
User-agent: *
Disallow: /wiki/
Disallow: /index.php?diff=
Disallow: /index.php?oldid=
Disallow: /index.php?title=Help
Disallow: /index.php?title=Image
Disallow: /index.php?title=MediaWiki
Disallow: /index.php?title=Special:
Disallow: /index.php?title=Template
Disallow: /skins/

# Allow the Internet Archiver to index action=raw and thereby store the raw wikitext of pages
User-agent: ia_archiver
Allow: /*&action=raw
<?php

// Dev environment
else:
?>
User-agent: *
Disallow: /
<?php
endif;
