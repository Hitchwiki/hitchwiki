<?php
/**
 * Settings for MediaWiki extensions
 *
 */


/**
 * VisualEditor
 * https://www.mediawiki.org/wiki/Extension:VisualEditor
 *
 * Problems with this Extension? See:
 * https://www.mediawiki.org/wiki/Extension:VisualEditor#Troubleshooting
 */
if(file_exists("$IP/extensions/VisualEditor/VisualEditor.php")) {
  wfLoadExtension('VisualEditor');
  // Enable by default for everybody
  $wgDefaultUserOptions['visualeditor-enable'] = 1;
  // Don't allow users to disable it
  $wgHiddenPrefs[] = 'visualeditor-enable';
  // OPTIONAL: Enable VisualEditor's experimental code features
  #$wgDefaultUserOptions['visualeditor-enable-experimental'] = 1;

  // Use $wgVirtualRestConfig instead of individual config vars to be future-proof:
  // https://www.mediawiki.org/wiki/Topic:Rbnlhxzcs7xumz3a
  $wgVirtualRestConfig['modules']['parsoid'] = array(
          // URL to the Parsoid instance
          // Use port 8142 if you use the Debian package
          'url' => 'http://' . $hwConfig["domain"] . ':8142',
          // Parsoid "domain"
          'domain' => $hwConfig["domain"],
          // Parsoid "prefix"
          'prefix' => $hwConfig["mediawiki"]["db"]["prefix"]
  );

  // Extra settings for VisualEditor
  // https://www.mediawiki.org/wiki/Extension:VisualEditor#Complete_list_of_configuration_options

  // If showing two edit tabs, where to put the VisualEditor edit tab in
  // relation to the system (or WikiEditor) one:
  $wgVisualEditorTabPosition = 'before'; // before|after

  // Whether to show the "welcome to the beta" dialog the first time a
  // user uses VisualEditor:
  $wgVisualEditorShowBetaWelcome = false;
}

/**
 * WikiEditor (code)
 * https://www.mediawiki.org/wiki/Extension:WikiEditor
 */
//wfLoadExtension('WikiEditor');
// Enables use of WikiEditor by default but still allows users to disable it in preferences
$wgDefaultUserOptions['usebetatoolbar'] = 1;

// Enables link and table wizards by default but still allows users to disable them in preferences
$wgDefaultUserOptions['usebetatoolbar-cgd'] = 1;

// Displays the Preview and Changes tabs
$wgDefaultUserOptions['wikieditor-preview'] = 1;

// Displays the Publish and Cancel buttons on the top right side
$wgDefaultUserOptions['wikieditor-publish'] = 1;


/**
 * GeoCrumbs
 * https://www.mediawiki.org/wiki/Extension:GeoCrumbs
 */
wfLoadExtension('GeoCrumbs');

/**
 * GeoData
 * https://www.mediawiki.org/wiki/Extension:GeoData
 */
wfLoadExtension('GeoData');

/**
 * MultimediaViewer
 * https://www.mediawiki.org/wiki/Extension:MultimediaViewer
 */
wfLoadExtension('MultimediaViewer');
$wgMediaViewerEnableByDefaultForAnonymous = true;
$wgMediaViewerEnableByDefault = true;

/**
 * HeaderTabs
 * https://www.mediawiki.org/wiki/Extension:Header_Tabs
 */
wfLoadExtension('HeaderTabs');

/**
 * AddBodyClass
 * https://www.mediawiki.org/wiki/Extension:AddBodyClass
 * Rather unmaintained extension.
 * We should see if functionality of this extension is
 * redundant now, or perhaps we can do it ourselves.
 */
require_once "$IP/extensions/AddBodyClass/AddBodyClass.php";

/**
 * AdminLinks
 * Define "Special:AdminLinks" page, that holds links meant to be helpful for wiki administrators
 * https://www.mediawiki.org/wiki/Extension:AdminLinks
 */
require_once "$IP/extensions/AdminLinks/AdminLinks.php";
$wgGroupPermissions['sysop']['adminlinks'] = true;

/**
 * DismissableSiteNotice
 * This can be disabled after /en/MediaWiki:Sitenotice is no more needed.
 * http://www.mediawiki.org/wiki/Extension:DismissableSiteNotice
 */
wfLoadExtension('DismissableSiteNotice');

/**
 * Semantic MediaWiki extensions
 * https://semantic-mediawiki.org/wiki/Help:Installation#Installation
 *
 * `SemanticMediaWikiEnabled` file is created during first `vagrant up` command
 * from `./scripts/server_install.sh` file. It's to ensure we don't load them
 * too early in process and cause DB errors.
 */
  wfLoadExtension('PageForms');

if (file_exists("$IP/extensions/SemanticMediaWikiEnabled")) {
  require_once "$IP/extensions/SemanticMediaWiki/SemanticMediaWiki.php";
  enableSemantics();
  require_once "$IP/extensions/Maps/Maps.php";

  // Sets whether help information on the edit page is displayed
  $smwgEnabledEditPageHelp = false;

  // For red links not defined by #formredlink and not pointing to
  // a form-associated namespace, you can have every such link point
  // to a helper page, that lets the user choose which of the wiki's forms
  // to use to create this page - or to use no form at all.
  $wgPageFormsLinkAllRedLinksToForms = true;


  // Renames the edit-with-form tab to just "Edit", and
  // the traditional-editing tab, if it is visible, to "Edit source",
  // in whatever language is being used.
  $wgPageFormsRenameEditTabs = false;

  // Renames only the traditional editing tab, to "Edit source".
  $wgPageFormsRenameMainEditTab = true;

  // You can have the set of values used for autocompletion in forms be cached, which may
  // improve performance. To do that, add something like the following to LocalSettings.php:
  $sfgCacheAutocompleteValues = true;
  $sfgAutocompleteCacheTimeout = 60 * 60 * 24; // 1 day (in seconds)
}

/**
 * ParserFunctions
 * https://www.mediawiki.org/wiki/Extension:ParserFunctions
 */
//wfLoadExtension('ParserFunctions');
// Enable old string functions (needed at our semantic templates)
$wgPFEnableStringFunctions = true;

/**
 * Interwiki links (nomadwiki, trashwiki etc)
 * - Grant sysops permissions to edit interwiki data
 * - See Database settings to understand how Interwiki settings are shared between wikis
 */
//wfLoadExtension('Interwiki');
$wgGroupPermissions['sysop']['interwiki'] = true;
// To create a new user group that may edit interwiki data
// (bureaucrats can add users to this group)
#$wgGroupPermissions['developer']['interwiki'] = true;
// Interwiki tables are shared between language versions
// https://www.mediawiki.org/wiki/Extension:Interwiki#Global_interwikis
$wgSharedTables[] = 'interwiki';

/**
 * CheckUser
 * https://www.mediawiki.org/wiki/Extension:CheckUser
 * Requires install, see scripts/server_install.sh
 */
#wfLoadExtension('CheckUser');
#$wgGroupPermissions['sysop']['checkuser'] = true;

/**
 * AntiSpoof
 * Preventing confusable usernames from being created.
 * It blocks the creation of accounts with mixed-script,
 * confusing and similar usernames.
 * https://www.mediawiki.org/wiki/Extension:AntiSpoof
 * Requires install, see scripts/server_install.sh
 */
require_once "$IP/extensions/AntiSpoof/AntiSpoof.php";
$wgSharedTables[] = 'spoofuser';

/**
 * ReplaceText
 * Provides a special page to allow administrators to do a global string
 * find-and-replace on both the text and titles of the wiki's content pages.
 * https://www.mediawiki.org/wiki/Extension:Replace_Text
 */
wfLoadExtension('ReplaceText');
$wgGroupPermissions['bureaucrat']['replacetext'] = true;

/**
 * AbuseFilter
 * Allow privileged users to set specific controls on actions by users,
 * such as edits, and create automated reactions for certain behaviors.
 * https://www.mediawiki.org/wiki/Extension:AbuseFilter
 */
require_once "$IP/extensions/AbuseFilter/AbuseFilter.php";
$wgGroupPermissions['sysop']['abusefilter-modify'] = true;
$wgGroupPermissions['*']['abusefilter-log-detail'] = true;
$wgGroupPermissions['*']['abusefilter-view'] = true;
$wgGroupPermissions['*']['abusefilter-log'] = true;
$wgGroupPermissions['sysop']['abusefilter-private'] = true;
$wgGroupPermissions['sysop']['abusefilter-modify-restricted'] = true;
$wgGroupPermissions['sysop']['abusefilter-revert'] = true;

/**
 * Echo
 * https://www.mediawiki.org/wiki/Extension:Echo
 */
require_once "$IP/extensions/Echo/Echo.php";
$wgEchoAgentBlacklist = array('Hitchbot', 'Hitchwiki');


/**
 * EventLogging
 * Required by original `$wgVectorBetaPersonalBar` of
 * https://www.mediawiki.org/wiki/Extension:VectorBeta
 *
 * ...but since that was buggy and anyway not needed,
 * we forked that unmaintained extension and removed this feature.
 * Thus this isn't needed anymore
 * Fork: https://github.com/Hitchwiki/mediawiki-extensions-VectorBeta
 *
 * https://www.mediawiki.org/wiki/Extension:EventLogging
 */
// require_once "$IP/extensions/EventLogging/EventLogging.php";
// $wgEventLoggingBaseUri = 'http://'.$hwConfig["general"]["domain"].':8080/event.gif';
// $wgEventLoggingFile = "{$logDir}/events.log";

/**
 * Adds some new features to MediaWiki and Vector theme
 * https://www.mediawiki.org/wiki/Beta_Features
 * https://www.mediawiki.org/wiki/Extension:BetaFeatures
 * https://www.mediawiki.org/wiki/Extension:VectorBeta
 *
 * Features are forced to be enabled to everyone using
 * https://github.com/Hitchwiki/BetaFeatureEverywhere
 * ...since by default users would need to opt-in to beta features.
 */
wfLoadExtension('BetaFeatures');
wfLoadExtension('HWVectorBeta');
require_once "$IP/extensions/BetaFeatureEverywhere/BetaFeatureEverywhere.php";
$wgBetaFeaturesWhitelist = array('betafeatures-vector-typography-update', 'betafeatures-vector-fixedheader');
$wgBetaFeaturesWhitelistLoggedIn = array('betafeatures-vector-compact-personal-bar');
$wgDefaultUserOptions['betafeatures-vector-compact-personal-bar'] = '1';
$wgDefaultUserOptions['betafeatures-vector-typography-update'] = '1';
$wgDefaultUserOptions['betafeatures-vector-fixedheader'] = '1';
$wgVectorBetaTypography = true;
$wgVectorBetaPersonalBar = true;
$wgVectorBetaWinter = true;

/**
 * LocalisationUpdate
 * https://www.mediawiki.org/wiki/Extension:LocalisationUpdate
 */
wfLoadExtension('LocalisationUpdate');
$wgLocalisationUpdateDirectory = "$IP/cache";

/**
 * Enables some features required by VectorBeta such as Special:MobileMenu
 * https://www.mediawiki.org/wiki/Extension:MobileFrontend
 */
require_once "$IP/extensions/MobileFrontend/MobileFrontend.php";
$wgMFAutodetectMobileView = true;
$wgMobileFrontendLogo = $wgScriptPath . "/../wiki-mobilelogo.png"; // Should be 35 × 22 px

/**
 * Rename user
 * https://www.mediawiki.org/wiki/Extension:Renameuser
 */
//wfLoadExtension('Renameuser');
$wgGroupPermissions['sysop']['renameuser'] = true;


/**
 * UploadWizard
 * https://www.mediawiki.org/wiki/Extension:UploadWizard
 */
wfLoadExtension('UploadWizard');
$wgUploadWizardConfig = array(
  'debug' => $hwDebug,
  #'autoCategory' => 'Uploaded with UploadWizard',
  #'feedbackPage' => '',
  'altUploadForm' => 'Special:Upload',
  'fallbackToAltUploadForm' => false,
  'enableFormData' => true,  # Should FileAPI uploads be used on supported browsers?
  'enableMultipleFiles' => true,
  'enableMultiFileSelect' => true,
  'tutorial' => array('skip' => true),
  'fileExtensions' => $wgFileExtensions # omitting this can cause errors
);
// Needed to make UploadWizard work in IE, see bug 39877
$wgApiFrameOptions = 'SAMEORIGIN';
$wgUploadNavigationUrl = '/'.$hwLang.'/Special:UploadWizard';
// This modifies the sidebar's "Upload file" link - probably in other places as well. More at Manual:$wgUploadNavigationUrl.
$wgExtensionFunctions[] = function() {
  $GLOBALS['wgUploadNavigationUrl'] = SpecialPage::getTitleFor('UploadWizard')->getLocalURL();
  return true;
};


/**
 * Hitchwiki extensions
 * https://github.com/Hitchwiki/
 */
require_once "$IP/extensions/HitchwikiVector/HitchwikiVector.php"; // Customized theme based on `Vector` theme
require_once "$IP/extensions/HWMap/HWMap.php"; // Hitchwiki Maps (see `/Special:HWMap` page)
require_once "$IP/extensions/HWWaitingTime/HWWaitingTime.php"; // Waiting time -feature
require_once "$IP/extensions/HWRatings/HWRatings.php"; // "Hithability" ratings -feature
require_once "$IP/extensions/HWComments/HWComments.php"; // Comments -feature
wfLoadExtension('HWLocationInput'); // `HW_Location` input type for PageForms extension

// Vendor configs for HW extensions
// See `settings.yml`
$hwGeonamesUsername = $hwConfig['mediawiki']['geonames']['username'];
$hwMapboxUsername = $hwConfig['mediawiki']['mapbox']['username'];
$hwMapboxAccessToken = $hwConfig['mediawiki']['mapbox']['access_token'];
$hwMapboxMapkeyStreets = $hwConfig['mediawiki']['mapbox']['mapkey_streets'];
$hwMapboxMapkeySatellite = $hwConfig['mediawiki']['mapbox']['mapkey_satellite'];
/*
//$hwGeonamesUsername = array_key_exists(['geonames']['username'], $hwConfig['mediawiki']) ? $hwConfig['vendor']['geonames_username'] : false;
$hwMapboxUsername = array_key_exists('mapbox_username', $hwConfig['vendor']) ? $hwConfig['vendor']['mapbox_username'] : false;
$hwMapboxAccessToken = array_key_exists('mapbox_access_token', $hwConfig['vendor']) ? $hwConfig['vendor']['mapbox_access_token'] : false;
$hwMapboxMapkeyStreets = array_key_exists('mapbox_mapkey_streets', $hwConfig['vendor']) ? $hwConfig['vendor']['mapbox_mapkey_streets'] : false;
$hwMapboxMapkeySatellite = array_key_exists('mapbox_mapkey_satellite', $hwConfig['vendor']) ? $hwConfig['vendor']['mapbox_mapkey_satellite'] : false;
*/

// Default settings for HW extensions
$hwDefaultCenter = array(48.6908333333, 9.14055555556); // `[(float) latitude, (float) longitude]` (Europe)
$hwDefaultZoom = 5; // 1-22, smaller the integer the higher  thezoom level
