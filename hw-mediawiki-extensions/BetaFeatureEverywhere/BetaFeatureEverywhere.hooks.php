<?php

class BetaFeatureEverywhereHooks {

  /**
  * Handler for UserLoadOptions
  * @param User $user
  * @param array $options
  * @return array $options
  */
  static function everywhere( $user, &$options) {
    global $wgDefaultUserOptions,
           $wgHiddenPrefs,
           $wgBetaFeaturesEverywhere,
           $wgBetaFeaturesWhitelist,
           $wgBetaFeaturesWhitelistLoggedIn;

    $features = array(
      'betafeatures-vector-compact-personal-bar',
      'betafeatures-vector-typography-update',
      'betafeatures-vector-fixedheader',
      'visualeditor-enable',
      'popups',
    );

    // $wgBetaFeaturesWhitelist should contain features whitelisted for everyone
    // $wgBetaFeaturesWhitelistLoggedIn should contain all features whitelisted for logged in users
    // Why this magic works: https://github.com/wikimedia/mediawiki-extensions-BetaFeatures/blob/3beab25f9d28e99b8d2ee2186c28125c3e0dcf80/includes/BetaFeaturesUtil.php#L35
    if( isset($wgBetaFeaturesWhitelist) && is_array($wgBetaFeaturesWhitelist) &&
      isset($wgBetaFeaturesWhitelistLoggedIn) && is_array($wgBetaFeaturesWhitelistLoggedIn) && 
      isset($user)
    ) {
      $wgBetaFeaturesWhitelist = array_merge($wgBetaFeaturesWhitelist, $wgBetaFeaturesWhitelistLoggedIn);
    }

    if(isset($wgBetaFeaturesEverywhere) && is_array($wgBetaFeaturesEverywhere)) {
      $features = array_merge($wgBetaFeaturesEverywhere, $features);
    }

    foreach($features as $feature) {

      if( isset($wgDefaultUserOptions[$feature]) ) {

        // Set feature on/off for also logged in users
        $options[$feature] = $wgDefaultUserOptions[$feature];

        // Hide feature from preferences
        $wgHiddenPrefs[] = $feature;
      }

    }

    return $options;
  }

}
