<?php

/**
 * Default extension settings (both positive integers!)
 */

$wgHwRatingsMinRating = 1;
$wgHwRatingsMaxRating = 5;

/* ------------------------------------------------------------------------ */

$wgExtensionCredits['HWRatings'][] = array(
  'path' => __FILE__,
  'name' => 'HWRatings',
  'version' => '1.0.0',
  'author' => array('Rémi Claude', 'Mikael Korpela', 'Olexandr Melnyk'),
  'url' => 'https://github.com/Hitchwiki/HWRatings-extension',
  'descriptionmsg' => 'hwratings-desc'
);

$dir = __DIR__;

// Register hook
$wgAutoloadClasses['SpecialRatingsMap'] = $IP . '/extensions/HWRatings/SpecialRatingsMap.php';
$wgSpecialPages['HWCountries'] = 'SpecialRatingsMap';

// Database hook
$wgAutoloadClasses['HWRatingsHooks'] = "$dir/HWRatingsHooks.php";
$wgHooks['LoadExtensionSchemaUpdates'][] = 'HWRatingsHooks::onLoadExtensionSchemaUpdates';

$wgMessagesDirs['HWRatings'] = __DIR__ . '/i18n';

// Deletion and undeletion hooks
$wgHooks['ArticleDeleteComplete'][] = 'HWRatingsHooks::onArticleDeleteComplete';
$wgHooks['ArticleRevisionUndeleted'][] = 'HWRatingsHooks::onArticleRevisionUndeleted';

// Register aliases
$wgExtensionMessagesFiles['HWRatingsAlias'] = __DIR__ . '/HWRatings.alias.php';
$wgExtensionMessagesFiles['HWCountriesAlias'] = __DIR__ . '/HWCountries.alias.php';

// APIs
$wgAutoloadClasses['HWRatingsBaseApi'] = "$dir/api/HWRatingsBaseApi.php";
$wgAutoloadClasses['HWAddRatingApi'] = "$dir/api/HWAddRatingApi.php";
$wgAutoloadClasses['HWDeleteRatingApi'] = "$dir/api/HWDeleteRatingApi.php";
$wgAutoloadClasses['HWAvgRatingApi'] = "$dir/api/HWAvgRatingApi.php";
$wgAutoloadClasses['HWGetRatingsApi'] = "$dir/api/HWGetRatingsApi.php";
$wgAutoloadClasses['HWCountryRatingsApi'] = "$dir/api/HWCountryRatingsApi.php";
$wgAPIModules['hwaddrating'] = 'HWAddRatingApi';
$wgAPIModules['hwdeleterating'] = 'HWDeleteRatingApi';
$wgAPIModules['hwavgrating'] = 'HWAvgRatingApi';
$wgAPIModules['hwgetratings'] = 'HWGetRatingsApi';
$wgAPIModules['hwgetcountryratings'] = 'HWCountryRatingsApi';

// Register assets
$wgHWRatingsResourceBoilerplate = array(
  'localBasePath' =>  __DIR__,
  'remoteExtPath' => 'HWRatings',
);
$wgResourceModules = array_merge( $wgResourceModules, array(
  // See https://github.com/bjornd/jvectormap
  'jvectormap' => $wgHWRatingsResourceBoilerplate + array(
    'scripts' => array(
      'modules/vendor/bower-jvectormap-2/jquery-jvectormap-2.0.0.min.js',
      'modules/vendor/jvectormap-world-hitchwiki-custom/jvectormap-world-hitchwiki-custom.js',
    ),
    'styles' => array(
      'modules/vendor/bower-jvectormap-2/jquery-jvectormap-2.0.0.css'
    )
  ),

  'ext.HWRatings' => $wgHWRatingsResourceBoilerplate + array(
    'dependencies' => array(
      'mediawiki.page.startup',
      'mediawiki.util',
      'jvectormap'
    ),
    'scripts' => array(
      'modules/js/ext.HWRatingsMapSpecial.js'
    ),
    'styles' => array(
      'modules/less/specialpage.less'
    ),
    // Other ensures this loads after the Vector skin styles
    'group' => 'other',
    'position' => 'bottom',
  )
) );

return true;
