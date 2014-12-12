<?php
/*
 * Hitchwiki Start Page
 */

$hwLangConfig = parse_ini_file("../configs/dev/languages.ini", true);

echo "<h1>Hitchwiki</h1>";

echo "<ul>";
foreach($hwLangConfig["languages"] as $code => $lang) {
  echo '<li><a href="./' . $code . '/">' . $lang . '</li>';
}
echo "</ul>";
