<?php
/**
 * LOAD HITCHWIKI CONFIG
 */
$hwConfVagrant = "/var/www/configs/mediawiki.php";
$hwConfRelative = "../../configs/mediawiki.php";

if(file_exists($hwConfVagrant)):
  require_once($hwConfVagrant);
else:
  require_once($hwConfRelative);
endif;
