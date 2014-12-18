<?php
/*
 * Hitchwiki language settings
 */

$hwLangConfig = parse_ini_file("languages.ini",true);

# Set the language
if(isset($_SERVER['REQUEST_URI'])) {
  $hwLangcodes = array_keys($hwLangConfig["languages"]);

  $hwLang = $hwLangcodes[ array_search( substr($_SERVER['REQUEST_URI'], 1, 2), $hwLangcodes ) ];
}

/*
 * Don't touch these lines, although they may look weird. Some shell
 * scripts replace them to loop maintenance over languages
 */
if ($wgCommandLineMode) {
  $cmdlang = 'en';
  $hwLang = $cmdlang;
}

# Fallback
if( !isset($hwLang) || !$hwLang || empty($hwLang) ) $hwLang = "en";

# Do we have special wikiname for this language?
if( isset($hwLangConfig["wikinames"][$hwLang]) ) $wgSitename = $hwLangConfig["wikinames"][$hwLang];
