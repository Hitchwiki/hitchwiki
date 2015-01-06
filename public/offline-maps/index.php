<?php
/*
 * List *.map files from this folder
 * @link https://github.com/Hitchwiki/hitchwiki/wiki/API#offline-vector-maps
 */

$files = scandir("./");
$format = (isset($_GET['format']) && $_GET['format'] == 'json') ? 'json' : 'html';

// Country names
// https://github.com/lukes/ISO-3166-Countries-with-Regional-Codes
$countries = json_decode( file_get_contents("./countries.json") );
$isocodes = array();
foreach($countries as $country) {
  $country = get_object_vars($country);
  $isocodes[$country["alpha-2"]] = $country["name"];
}

// No cache
header("Cache-Control: no-cache, must-revalidate"); // HTTP/1.1
header("Expires: Sat, 26 Jul 1997 05:00:00 GMT"); // Date in the past


// MB instead of bytes
// http://php.net/manual/en/function.filesize.php#106569
function human_filesize($bytes, $decimals = 2) {
  $sz = 'BKMGTP';
  $factor = floor((strlen($bytes) - 1) / 3);
  return sprintf("%.{$decimals}f", $bytes / pow(1024, $factor)) . @$sz[$factor];
}


// Return JSON
if($format == 'json'):

  $json = array();

  foreach($files as $file) {
    if(substr($file, -4) === '.map' && is_file($file)) {
      $size = filesize($file);
      $mtime = filemtime($file);
      $code = str_replace(".map", "", $file);
      $name = (isset($isocodes[$code])) ? $isocodes[$code] : false;

      $json[$code] = array(
        'file' => $file,
        'size' => $size,
        //'size_readable' => human_filesize( $size, 1),
        'modified' => $mtime,
        //'modified_readable' => date ("j.n.Y", $mtime),
      );
      if($name) {
        $json[$code]['name'] = $name;
      }

    }
  }

  header('Content-Type: application/json');
  echo json_encode($json);

// Return HTML
else:

  echo '<html><head><title>Offline tiles for Hitchwiki maps</title></head><body>';
  echo '<h1>Offline tiles for Hitchwiki maps</h1>';
  echo '<p>Please don\'n download these from this server without <a href="http://hitchwiki.org/contact/">contacting us first</a>. Refer to <a href="https://github.com/Hitchwiki/hitchwiki/wiki/API#offline-vector-maps">documentation</a> for more info.</p>';
  echo '<table cellpadding="5" cellspacing="0" border="0">';

  foreach($files as $file) {
    if(substr($file, -4) === '.map' && is_file($file)) {
      $size = filesize($file);
      $mtime = filemtime($file);
      $code = str_replace(".map", "", $file);
      $name = (isset($isocodes[$code])) ? $isocodes[$code] : false;

      echo '<tr>';
      echo ($name) ? '<td>' . $name . '</td>' : '<td></td>';
      echo '<td><a href="' . $file . '">' . $file . '</a></td>';
      echo '<td>' . human_filesize( filesize($file), 1) . '</td>';
      echo '<td>' . date ("Y-m-d", $mtime) . '</td>';
      echo '</tr>';
    }
  }

  echo '</table>';
  echo '</body></html>';

endif;
