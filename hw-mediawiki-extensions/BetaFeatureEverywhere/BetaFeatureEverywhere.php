<?php

$wgExtensionCredits['betafeatures'][] = array(
  'path' => __FILE__,
  'name' => 'BetaFeatureEverywhere',
  'version' => '0.0.2',
  'author' => 'Mikael Korpela',
  'description' => 'Force MediaWiki beta features for everyone everywhere everytime.'
);

$wgAutoloadClasses['BetaFeatureEverywhereHooks'] = __DIR__ . '/BetaFeatureEverywhere.hooks.php';

$wgHooks['UserLoadOptions'][] = 'BetaFeatureEverywhereHooks::everywhere';

// Return true so that MediaWiki continues to load extensions.
return true;
