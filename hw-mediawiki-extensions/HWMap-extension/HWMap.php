<?php
if ( !defined( 'MEDIAWIKI' ) ) die();
/**
 * hitchwiki map extension
 * <hwmap></hwmap>
 */

/**
 * "Radius" of the square bounding box within which cities are deemed relevant
 * to the spot
 *
 * Reference: http://www.movable-type.co.uk/scripts/latlong-db.html
 *
 *  -------------NE
 * |              |
 * |        radius|
 * |       o------|
 * |              |
 * |              |
 * SW-------------
 *
 * Relevant for HWFindNearbyCity API call
 */

$wgHwMapCityRelevanceRadius = 15000; // in meters

/**
 * Difference between distances from the spot to the two closest cities
 * that is considered small enough to consider them both equally relevant
 *
 * If the difference is higher than this value, only one closest city will be
 * included in the result set
 *
 * Relevant for HWFindNearbyCity API call
 */

$wgHwMapCityCloseDistance = 2500; // in meters

/**
 * Minimum population of a place to be considered a "big city", when it's
 * neither a country capital, nor a regional capital (eg. Rotterdam)
 *
 * Relevant for HWFindNearbyCity API call
 */

$wgHwMapBigCityMinPopulation = 500000;

/* ------------------------------------------------------------------------ */

// Kudos
// deprecated
// https://www.mediawiki.org/wiki/Manual:$wgExtensionCredits
$wgExtensionCredits['HWMap'][] = array(
  'path' => __FILE__,
  'name' => 'HWMap',
  'descriptionmsg' => 'hwmap-desc',
  'author' => array('Rémi Claude', 'Mikael Korpela', 'Olexandr Melnyk'),
  'url' => 'https://github.com/Hitchwiki/HWMap-extension',
  'version' => '2.1.0',
  'license-name' => 'MIT'
);

// Register hook
$wgHooks['ParserFirstCallInit'][] = 'onParserInit';
$wgHooks['ResourceLoaderGetConfigVars'][] = 'onResourceLoaderGetConfigVars';

// Extension & magic words i18n
$wgMessagesDirs['HWMap'] = __DIR__ . '/i18n';

// Register aliases
$wgExtensionMessagesFiles['HWMapAlias'] = __DIR__ . '/HWMap.alias.php';

// Register special pages
$wgAutoloadClasses['SpecialHWMap'] = $IP . '/extensions/HWMap/SpecialHWMap.php';
$wgSpecialPages['HWMap'] = 'SpecialHWMap';

// Register API
$wgAutoloadClasses['SphericalGeometry'] = __DIR__ . '/lib/SphericalGeometry/spherical-geometry.class.php';
$wgAutoloadClasses['HWMapApi'] = __DIR__ . '/api/HWMapApi.php';
$wgAutoloadClasses['HWMapCityApi'] = __DIR__ . '/api/HWMapCityApi.php';
$wgAutoloadClasses['HWSpotIdApi'] = __DIR__ . '/api/HWSpotIdApi.php';
$wgAutoloadClasses['HWFindNearbyCityApi'] = __DIR__ . '/api/HWFindNearbyCityApi.php';
$wgAutoloadClasses['HWGeocoderApi'] = __DIR__ . '/api/HWGeocoderApi.php';
$wgAPIModules['hwmap'] = 'HWMapApi';
$wgAPIModules['hwmapcity'] = 'HWMapCityApi';
$wgAPIModules['hwspotid'] = 'HWSpotIdApi';
$wgAPIModules['hwfindnearbycity'] = 'HWFindNearbyCityApi';
$wgAPIModules['hwgeocoder'] = 'HWGeocoderApi';

// Register assets
$wgHWMapResourceBoilerplate = array(
  'localBasePath' => __DIR__,
  'remoteExtPath' => 'HWMap',
);
$wgResourceModules = array_merge( $wgResourceModules, array(

  'leaflet' => $wgHWMapResourceBoilerplate + array(
    'scripts' => array(
      'modules/vendor/leaflet/dist/leaflet.js',
      'modules/js/bindings/ext.HWMap.Leaflet.binding.js'
    ),
    'styles' => array(
      'modules/vendor/leaflet/dist/leaflet.css',
    ),
  ),

  'prunecluster' => $wgHWMapResourceBoilerplate + array(
    'dependencies' => array(
      'leaflet'
    ),
    'scripts' => array(
      'modules/vendor/PruneCluster/dist/PruneCluster.js',
      'modules/js/bindings/ext.HWMap.PruneCluster.binding.js'
    ),
    'styles' => array(
      'modules/vendor/PruneCluster/dist/LeafletStyleSheet.css',
    ),
  ),

  'ractive' => $wgHWMapResourceBoilerplate + array(
    'scripts' => array(
      'modules/vendor/ractive/ractive.js',
      'modules/js/bindings/ext.HWMap.Ractive.binding.js'
    )
  ),

  'autosize' => $wgHWMapResourceBoilerplate + array(
    'scripts' => array(
      'modules/vendor/autosize/dist/autosize.js',
      'modules/js/bindings/ext.HWMap.Autosize.binding.js'
    )
  ),

  'lodash' => $wgHWMapResourceBoilerplate + array(
    'scripts' => array(
      'modules/vendor/lodash/dist/lodash.js',
      'modules/js/bindings/ext.HWMap.Lodash.binding.js'
    )
  ),

  'ext.HWMap.SpecialPage' => $wgHWMapResourceBoilerplate + array(
    'scripts' => array(
      'modules/js/ext.HWMap.SpecialPage.js',
    )
  ),
  'ext.HWMap.City' => $wgHWMapResourceBoilerplate + array(
    'scripts' => array(
      'modules/js/ext.HWMap.City.js',
    )
  ),
  'ext.HWMap.Country' => $wgHWMapResourceBoilerplate + array(
    'scripts' => array(
      'modules/js/ext.HWMap.Country.js',
    )
  ),
  'ext.HWMap.CountryRating' => $wgHWMapResourceBoilerplate + array(
    'scripts' => array(
      'modules/js/ext.HWMap.CountryRating.js',
    )
  ),
  'ext.HWMap.Toolbar' => $wgHWMapResourceBoilerplate + array(
    'scripts' => array(
      'modules/js/ext.HWMap.Toolbar.js',
    )
  ),
  'ext.HWMap.NewSpot' => $wgHWMapResourceBoilerplate + array(
    'scripts' => array(
      'modules/js/ext.HWMap.NewSpot.js',
    )
  ),

  'ext.HWMap' => $wgHWMapResourceBoilerplate + array(
    'dependencies' => array(
      'mediawiki.page.startup',
      'mediawiki.jqueryMsg', // https://www.mediawiki.org/wiki/Manual:Messages_API#Using_messages_in_JavaScript
      'mediawiki.notify',
      'mediawiki.util',
      'oojs-ui-core',
      'oojs-ui-widgets',
      'jquery.tipsy', // @TODO: deprecated in MW 1.28
      'jquery.spinner',
      'leaflet',
      'prunecluster',
      'ractive',
      'autosize',
      'lodash'
    ),
    'scripts' => array(
      'modules/js/ext.HWMap.js',
      'modules/js/ext.HWMap.DecimalAdjust.js',
      'modules/js/ext.HWMap.GeoPoint.js',
      'modules/js/ext.HWMap.Spots.js',
      'modules/js/ext.HWMap.Comments.js',
      'modules/js/ext.HWMap.Waitingtimes.js',
      'modules/js/ext.HWMap.Ratings.js',
      'modules/js/ext.HWMap.Map.js'
    ),
    'styles' => array(
      'modules/less/ext.HWMap.less',
    ),
    // These the language strings passed on to the frontend so that they can
    // be used like this in JS: `mw.message('key').text()`
    // https://www.mediawiki.org/wiki/Manual:Messages_API#Using_messages_in_JavaScript
    'messages' => array(
      'hwmap-hitchability-very-good',
      'hwmap-hitchability-good',
      'hwmap-hitchability-average',
      'hwmap-hitchability-bad',
      'hwmap-hitchability-senseless',
      'hwmap-hitchability-unknown',
      'hwmap-please-reload',
      'hwmap-please-try-again',
      'hwmap-error-loading-markers',
      'hwmap-error-geocoder',
      'hwmap-error-getting-spots',
      'hwmap-error-rating-add',
      'hwmap-error-rating-delete',
      'hwmap-error-waitingtimes-load',
      'hwmap-error-comment-delete',
      'hwmap-error-comment-add',
      'hwmap-error-comment-load',
      'hwmap-error-spot-load',
      'hwmap-confirm-removing-waitingtime',
      'hwmap-missing-waitingtime',
      'hwmap-open-cityname',
      'hwmap-open-city',
      'hwmap-wait',
      'hwmap-continue',
      'hwmap-read-more',
      'hwmap-city-no-spots'
    ),
    // `other` ensures this loads after the Vector skin styles
    'group' => 'other',
    'position' => 'bottom',
  )
) );

/**
 * The hook registration function.
 */
function onParserInit( Parser $parser ) {
  global $wgOut;
  $parser->setHook('hw-map', 'HWMapRender');
  $parser->setHook('hw-country-rate', 'HWCountryRatingRender');
  $wgOut->addModules('ext.HWMap');
  return true;
}

/**
 * Render `[hw-map]` tag
 */
function HWMapRender( $input, array $args, Parser $parser, PPFrame $frame ) {
  $result = file_get_contents(__DIR__ .'/modules/templates/ext.HWMap.City.template.html');

  return $result;
}

/**
 * Render `[hw-country-rate]` tag
 */
function HWCountryRatingRender( $input, array $args, Parser $parser, PPFrame $frame ) {
  $result = file_get_contents(__DIR__ .'/modules/templates/ext.HWMap.CountryRating.html');

  return $result;
}

/**
 * Expose config variables to JS frontend. Read them by:
 * ```
 * mw.config.get('keyname');
 * ```
 * Where keyname is e.g. `hwMapBoxUsername` or `hwDefaultCenter`.
 *
 * Set default value if config key doesn't exist:
 * ```
 * mw.config.get('keyname', 'defaultvalue');
 * ```
 *
 * https://www.mediawiki.org/wiki/Manual:Interface/JavaScript#mw.config
 */
function onResourceLoaderGetConfigVars( array &$vars ) {

  // Defined at MediaWiki config file
  global $hwMapboxUsername,
         $hwMapboxAccessToken,
         $hwMapboxMapkeyStreets,
         $hwMapboxMapkeySatellite,
         $hwDefaultCenter,
         $hwDefaultZoom,
         $wgHwMapBigCityMinPopulation;

  // MapBox config
  $vars['hwMapboxUsername'] = isset($hwMapboxUsername) ? $hwMapboxUsername : false;
  $vars['hwMapboxAccessToken'] = isset($hwMapboxAccessToken) ? $hwMapboxAccessToken : false;
  $vars['hwMapboxMapkeyStreets'] = isset($hwMapboxMapkeyStreets) ? $hwMapboxMapkeyStreets : false;
  $vars['hwMapboxMapkeySatellite'] = isset($hwMapboxMapkeySatellite) ? $hwMapboxMapkeySatellite : false;

  // Default center for maps (Europe)
  // `[(float) latitude, (float) longitude]`
  $vars['hwDefaultCenter'] = isset($hwDefaultCenter) ? $hwDefaultCenter : array(48.6908333333, 9.14055555556);

  // Default zoom for maps (integer 1-22)
  $vars['hwDefaultZoom'] = isset($hwDefaultZoom) ? $hwDefaultZoom : 5;

  // Geocoder settings
  $vars['wgHwMapBigCityMinPopulation'] = isset($wgHwMapBigCityMinPopulation) ? $wgHwMapBigCityMinPopulation : 500000;

  return true;
}
