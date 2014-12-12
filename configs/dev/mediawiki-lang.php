<?php
/*
* Settings for setting the language
*/

$hwLangConfig = parse_ini_file("languages.ini",true);

# Set the language
if(isset($_SERVER['REQUEST_URI'])) {
  $langcodes = array_keys($hwLangConfig["languages"]);

  $lang = $langcodes[ array_search( substr($_SERVER['REQUEST_URI'], 1, 2), $langcodes ) ];
}

# Fallback
if( !$lang || empty($lang) ) $lang = "en";

# Do we have special wikiname for this language?
if( isset($hwLangConfig["wikinames"][$lang]) ) $wgSitename = $hwLangConfig["wikinames"][$lang];
