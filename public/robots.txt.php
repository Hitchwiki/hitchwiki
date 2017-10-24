<?php
/* robots.txt
 * http://www.robotstxt.org/
 * https://www.mediawiki.org/wiki/Manual:Robots.txt
 */

header("Content-Type: text/plain");

require_once 'mustangostang/spyc/spyc.php';
if (!function_exists('spyc_load_file')) {
  die('Missing `mustangostang/spyc`!');
}
$hwConfig = spyc_load_file('../../configs/settings.yaml');

if(isset($hwConfig['mediawiki']['visible_to_search_engines']) && $hwConfig['mediawiki']['visible_to_search_engines'] === true):
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
