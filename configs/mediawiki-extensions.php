<?php
/**
 * Settings for MediaWiki extensions
 *
 */


/**
 * VisualEditor
 * https://www.mediawiki.org/wiki/Extension:VisualEditor
 */
wfLoadExtension('VisualEditor');
// Enable by default for everybody
$wgDefaultUserOptions['visualeditor-enable'] = 1;
// Don't allow users to disable it
$wgHiddenPrefs[] = 'visualeditor-enable';
// OPTIONAL: Enable VisualEditor's experimental code features
#$wgDefaultUserOptions['visualeditor-enable-experimental'] = 1;
// URL to the Parsoid instance
// MUST NOT end in a slash due to Parsoid bug
// Use port 8142 if you use the Debian package
$wgVisualEditorParsoidURL = 'http://' . $hwConfig["general"]["domain"] . ':8142';
// Interwiki prefix to pass to the Parsoid instance
// Parsoid will be called as $url/$prefix/$pagename
$wgVisualEditorParsoidPrefix = $hwConfig["general"]["domain"];


/**
 * WikiEditor (code)
 * https://www.mediawiki.org/wiki/Extension:WikiEditor
 */
require_once "$IP/extensions/WikiEditor/WikiEditor.php";
# Enables use of WikiEditor by default but still allow users to disable it in preferences
$wgDefaultUserOptions['usebetatoolbar'] = 1;
$wgDefaultUserOptions['usebetatoolbar-cgd'] = 1;
# Displays the Preview and Changes tabs
$wgDefaultUserOptions['wikieditor-preview'] = 1;
# Displays the Publish and Cancel buttons on the top right side
$wgDefaultUserOptions['wikieditor-publish'] = 1;


require_once "$IP/extensions/GeoCrumbs/GeoCrumbs.php";
require_once "$IP/extensions/GeoData/GeoData.php";
require_once "$IP/extensions/ExternalData/ExternalData.php";
require_once "$IP/extensions/MultimediaViewer/MultimediaViewer.php";
require_once "$IP/extensions/ApiSandbox/ApiSandbox.php";
require_once "$IP/extensions/OAuth/OAuth.php";
require_once "$IP/extensions/HeaderTabs/HeaderTabs.php";
require_once "$IP/extensions/AddBodyClass/AddBodyClass.php";

# Define "Special:AdminLinks" page, that holds links meant to be helpful for wiki administrators
require_once "$IP/extensions/AdminLinks/AdminLinks.php";
$wgGroupPermissions['my-group']['adminlinks'] = true;

# This can be disabled after http://hitchwiki.org/en/MediaWiki:Sitenotice is no more needed.
# http://www.mediawiki.org/wiki/Extension:DismissableSiteNotice
require_once "$IP/extensions/DismissableSiteNotice/DismissableSiteNotice.php";

# Semantic MediaWiki extensions
# These were installed via composer directly at MediaWiki folder and Composer takes care loading them
# https://semantic-mediawiki.org/wiki/Help:Installation#Installation

//require_once "$IP/extensions/SemanticMediaWiki/SemanticMediaWiki.php";
if(file_exists("$IP/extensions/SemanticMediaWiki/SemanticMediaWiki.php")) {
  enableSemantics();
  require_once "$IP/extensions/Maps/Maps.php";
  require_once "$IP/extensions/SemanticMaps/SemanticMaps.php";
  require_once "$IP/extensions/SemanticForms/SemanticForms.php";
  require_once "$IP/extensions/SemanticFormsInputs/SemanticFormsInputs.php";
  require_once "$IP/extensions/SemanticWatchlist/SemanticWatchlist.php";

  // Sets whether help information on the edit page is displayed
  $smwgEnabledEditPageHelp = false;


  // You can have the set of values used for autocompletion in forms be cached, which may
  // improve performance. To do that, add something like the following to LocalSettings.php:
  $sfgCacheAutocompleteValues = true;
  $sfgAutocompleteCacheTimeout = 60 * 60 * 24; // 1 day (in seconds)
}

# Enable old string functions (needed at our semantic templates)
require_once "$IP/extensions/ParserFunctions/ParserFunctions.php";
$wgPFEnableStringFunctions = true;

# Interwiki links (nomadwiki, trashwiki etc)
# - Grant sysops permissions to edit interwiki data
# - See Database settings to understand how Interwiki settings are shared between wikis
require_once "$IP/extensions/Interwiki/Interwiki.php";
$wgGroupPermissions['sysop']['interwiki'] = true;
// To create a new user group that may edit interwiki data
// (bureaucrats can add users to this group)
#$wgGroupPermissions['developer']['interwiki'] = true;

# Recent changes cleanup
# https://www.mediawiki.org/wiki/Extension:Recent_Changes_Cleanup
// require_once "$IP/extensions/RecentChangesCleanup/RecentChangesCleanup.php";
// $wgAvailableRights[] = 'recentchangescleanup';
// $wgGroupPermissions['sysop']['recentchangescleanup'] = true;
// $wgGroupPermissions['recentchangescleanup']['recentchangescleanup'] = true;

# CheckUser
# https://www.mediawiki.org/wiki/Extension:CheckUser
# Requires install, see scripts/vagrant_bootstrap.sh
#require_once "$IP/extensions/CheckUser/CheckUser.php";
#$wgGroupPermissions['sysop']['checkuser'] = true;

# Preventing confusable usernames from being created.
# It blocks the creation of accounts with mixed-script,
# confusing and similar usernames.
# https://www.mediawiki.org/wiki/Extension:AntiSpoof
# Requires install, see scripts/vagrant_bootstrap.sh
require_once "$IP/extensions/AntiSpoof/AntiSpoof.php";
$wgSharedTables[] = 'spoofuser';

# Provides a special page to allow administrators to do a global string
# find-and-replace on both the text and titles of the wiki's content pages.
require_once "$IP/extensions/ReplaceText/ReplaceText.php";
$wgGroupPermissions['bureaucrat']['replacetext'] = true;

# Allow privileged users to set specific controls on actions by users,
# such as edits, and create automated reactions for certain behaviors.
# https://www.mediawiki.org/wiki/Extension:AbuseFilter
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
#require_once "$IP/extensions/Echo/Echo.php";
$wgEchoAgentBlacklist = array( 'Hitchbot', 'Hitchwiki' );

/**
 * Adds some features into Vector theme
 * https://www.mediawiki.org/wiki/Extension:VectorBeta
 */
wfLoadExtension( 'BetaFeatures' );
wfLoadExtension( 'VectorBeta' );
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
require_once "$IP/extensions/LocalisationUpdate/LocalisationUpdate.php";
$wgLocalisationUpdateDirectory = "$IP/cache";


/**
 * Enables some features required by VectorBeta such as Special:MobileMenu
 * https://www.mediawiki.org/wiki/Extension:MobileFrontend
 */
// require_once "$IP/extensions/Mantle/Mantle.php"; // MobileFrontend requires Mantle
require_once "$IP/extensions/MobileFrontend/MobileFrontend.php";
$wgMFAutodetectMobileView = true;
$wgMobileFrontendLogo = $wgScriptPath . "/../wiki-mobilelogo.png"; // Should be 35 × 22 px

/**
 * Rename user
 */
require_once "$IP/extensions/Renameuser/Renameuser.php";
$wgGroupPermissions['sysop']['renameuser'] = true;


/**
 * EventLogging
 * Required by $wgVectorBetaPersonalBar
 * https://www.mediawiki.org/wiki/Extension:EventLogging
 */
require_once "$IP/extensions/EventLogging/EventLogging.php";
$wgEventLoggingBaseUri = 'http://'.$hwConfig["general"]["domain"].':8080/event.gif';
$wgEventLoggingFile = "{$logDir}/events.log";


/**
 * UploadWizard
 * https://www.mediawiki.org/wiki/Extension:UploadWizard
 */
require_once "$IP/extensions/UploadWizard/UploadWizard.php";
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
  $GLOBALS['wgUploadNavigationUrl'] = SpecialPage::getTitleFor( 'UploadWizard' )->getLocalURL();
  return true;
};


/**
 * Hitchwiki extensions
 * https://github.com/Hitchwiki/
 */
require_once "$IP/extensions/HitchwikiVector/HitchwikiVector.php";
require_once "$IP/extensions/HWMap/HWMap.php";
require_once "$IP/extensions/HWWaitingTime/HWWaitingTime.php";
require_once "$IP/extensions/HWRatings/HWRatings.php";
require_once "$IP/extensions/HWComments/HWComments.php";
