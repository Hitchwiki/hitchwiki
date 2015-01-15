<?php
#
# Hitchwiki MediaWiki configuration
#
# See /public/wiki/includes/DefaultSettings.php for all configurable settings
# and their default values, but don't forget to make changes in _this_
# file, not there.
#
# Further documentation for configuration settings may be found at:
# https://www.mediawiki.org/wiki/Manual:Configuration_settings

# Protect against web entry
if ( !defined( 'MEDIAWIKI' ) ) {
  exit;
}

# If PHP's memory limit is very low, some operations may fail.
ini_set('memory_limit', '64M');

# Load Hitchwiki Config
$hwConfig = parse_ini_file("settings.ini", true);

if ($wgCommandLineMode) {
  if (isset($_SERVER) && array_key_exists( 'REQUEST_METHOD', $_SERVER))
  die("This script must be run from the command line\n");
} elseif (empty($wgNoOutputBuffer)) {
  // Compress output if the browser supports it
  if (!ini_get( 'zlib.output_compression')) @ob_start('ob_gzhandler');
}

## Uncomment this to disable output compression
# $wgDisableOutputCompression = true;

$wgSitename = $hwConfig["general"]["sitename"];
$wgMetaNamespace = $hwConfig["general"]["metanamespace"];

##
## Dev environment settings
##
$hwDebug = ($hwConfig['general']['debug']) ? true : false;
$hwCache = ($hwConfig['general']['cache']) ? true : false;

if(isset($hwConfig['general']['env']) && $hwConfig['general']['env'] == 'dev') {

  // Enable error reporting
  if($hwDebug) {
    error_reporting( -1 );
    ini_set( 'display_errors', 1 );
  }

  // Show the debug toolbar if 'debug' is set on the request, either as a
  // parameter or a cookie.
  if ( !empty( $_REQUEST['debug'] ) ) {
    $wgDebugToolbar = true;
  }

  // Expose debug info for PHP & SQL errors.
  $wgShowExceptionDetails = $hwDebug;
  $wgDevelopmentWarnings = $hwDebug;
  $wgDebugDumpSql = $hwDebug;
  $wgShowDBErrorBacktrace = $hwDebug;
  $wgShowSQLErrors = $hwDebug;
  $wgResourceLoaderDebug = $hwDebug;

  // Profiling
  $wgDebugProfiling = false;

  // Log into file
  $logDir = '/vagrant/logs';
  $wgDebugLogFile = "{$logDir}/mediawiki-debug.log";
  foreach ( array( 'exception', 'runJobs', 'JobQueueRedis' ) as $logGroup ) {
    $wgDebugLogGroups[$logGroup] = "{$logDir}/mediawiki-{$logGroup}.log";
  }

  # Disable caching
  $wgEnableParserCache = $hwCache;
  $wgCachePages = $hwCache;
}

## Setup $hwLang
## Will also change $wgSitename if it finds local name
require_once("mediawiki-lang.php");

## When you make changes to this configuration file, this will make
## sure that cached pages are cleared.
$configdate      = gmdate( 'YmdHis', @filemtime( __FILE__ ) );
$wgCacheEpoch    = max($wgCacheEpoch, $configdate);

## The URL base path to the directory containing the wiki;
## defaults for all runtime URL paths are based off of this.
## For more information on customizing the URLs
## (like /w/index.php/Page_title to /wiki/Page_title) please see:
## https://www.mediawiki.org/wiki/Manual:Short_URL
$wgScriptPath       = "/" . $hwLang;
$wgScriptExtension  = ".php";
$wgArticlePath      = "{$wgScriptPath}/$1";
$wgScript           = "{$wgScriptPath}/index.php";
$wgUsePathInfo      = true;
$wgCookieDomain     = $hwConfig["general"]["cookiedomain"];

# Site language code, should be one of the list in ./languages/Names.php
$wgLanguageCode = $hwLang;

## The protocol and server name to use in fully-qualified URLs
$wgServer = "http://" . $hwConfig["general"]["domain"];

## The relative URL path to the skins directory
$wgStylePath = $wgScriptPath . "/skins";


## The relative URL path to the logo and icons
$wgLogo = $wgScriptPath . "/../wiki-logo.png";
$wgAppleTouchIcon = $wgScriptPath . "/../apple-touch-icon.png";
$wgFavicon = $wgScriptPath . "/../favicon.png";

## UPO means: this is also a user preference option

$wgEnableEmail = true;
$wgEnableUserEmail = true; # UPO

$wgEmergencyContact = "contact@" . $hwConfig["general"]["domain"];
$wgPasswordSender = "noreply@" . $hwConfig["general"]["domain"];

$wgEnotifUserTalk = false; # UPO
$wgEnotifWatchlist = false; # UPO
$wgEmailAuthentication = true;

## Database settings
$wgDBtype     = "mysql";
$wgDBserver   = $hwConfig["db"]["host"];
$wgDBname     = $hwConfig["db"]["database"];
$wgDBuser     = $hwConfig["db"]["username"];
$wgDBpassword = $hwConfig["db"]["password"];

# MySQL specific settings
$wgDBprefix = $hwConfig["db"]["prefix"];

# MySQL table options to use during installation or update
$wgDBTableOptions = "ENGINE=InnoDB, DEFAULT CHARSET=binary";

# Experimental charset support for MySQL 5.0.
$wgDBmysql5 = true;

## Shared memory settings
## https://www.mediawiki.org/wiki/Manual:$wgMainCacheType
## https://www.mediawiki.org/wiki/Memcached
if($hwCache) {
  $wgMemCachedPersistent = false;
  $wgUseMemCached = true;
  $wgMainCacheType = CACHE_MEMCACHED;
  $wgParserCacheType = CACHE_MEMCACHED;
  $wgMemCachedTimeout = 5000000;
  $wgMemCachedInstanceSize = 2000;
  $wgMemCachedServers = array('127.0.0.1:11211');
  $wgResourceLoaderMaxage['unversioned'] = 1;
}
else {
  $wgMainCacheType = CACHE_NONE;
}


## To enable image uploads, make sure the 'images' directory
## is writable, then set this to true:
# ImageMagick is required by UploadWizard extension
$wgEnableUploads = true;
$wgUseImageMagick = true;
$wgImageMagickConvertCommand = "/usr/bin/convert";

## To enable image uploads, make sure the 'images' directory
## is writable, then set this to true:
$wgEnableUploads = true;
$wgGenerateThumbnailOnParse = false;

$wgUploadPath       = $wgScriptPath . "/images/" . $hwLang;
$wgUploadDirectory  = $IP . "/images/" . $hwLang;

# Allowed file extensions for uploading files
$wgFileExtensions = array(
  'png', 'gif', 'jpg', 'jpeg', 'svg', 'pdf',
  'PNG', 'GIF', 'JPG', 'JPEG', 'SVG', 'PDF',
);

$wgUseCommaCount = false;

# InstantCommons allows wiki to use images from http://commons.wikimedia.org
$wgUseInstantCommons = true;

## If you use ImageMagick (or any other shell command) on a
## Linux server, this will need to be set to the name of an
## available UTF-8 locale
$wgShellLocale = "en_US.utf8";

## If you want to use image uploads under safe mode,
## create the directories images/archive, images/thumb and
## images/temp, and make them all writable. Then uncomment
## this, if it's not already uncommented:
#$wgHashedUploadDirectory = false;

## Set $wgCacheDirectory to a writable directory on the web server
## to make your wiki go slightly faster. The directory should not
## be publically accessible from the web.
$wgCacheDirectory = "$IP/cache";

$wgSecretKey = $hwConfig["general"]["secretkey"];

# Site upgrade key. Must be set to a string (default provided) to turn on the
# web installer while LocalSettings.php is in place
$wgUpgradeKey = $hwConfig["general"]["upgradekey"];

## For attaching licensing metadata to pages, and displaying an
## appropriate copyright notice / icon. GNU Free Documentation
## License and Creative Commons licenses are supported so far.

$wgEnableCreativeCommonsRdf = true;
$wgRightsPage               = ""; // Set to the title of a wiki page that describes your license/copyright
$wgRightsUrl                = "http://creativecommons.org/licenses/by-sa/4.0/";
$wgRightsText               = "Creative Commons Attribution-Share Alike";
$wgRightsIcon               = "${wgStylePath}/common/images/cc-by-sa.png";


$wgAllowDisplayTitle = true;

# CSS
$wgUseSiteCss        = true;
$wgAllowUserCss      = true;

# Path to the GNU diff3 utility. Used for conflict resolution.
$wgDiff3 = "/usr/bin/diff3";

# Recent changes patrolling
$wgShowUpdatedMarker             = true;
$wgAllowCategorizedRecentChanges = true;
$wgAllowCategorizedRecentChanges = true;
$wgPutIPinRC                     = true;
$wgUseRCPatrol                   = true;

# Permissions
$wgGroupPermissions['*']['edit'] = false;

# API
$wgEnableAPI = true;
$wgEnableWriteAPI = true;


/***** Skins ******************************************************************************************/

## Default skin: you can change the default skin. Use the internal symbolic
## names, ie 'vector', 'monobook':
$wgDefaultSkin = "vector";

# Enabled skins
require_once "$IP/skins/CologneBlue/CologneBlue.php";
require_once "$IP/skins/Modern/Modern.php";
require_once "$IP/skins/MonoBook/MonoBook.php";
require_once "$IP/skins/Vector/Vector.php";


/***** Extensions ******************************************************************************************/

require_once "$IP/extensions/CustomData/CustomData.php"; // CustomData is needed by GeoCrumbs
require_once "$IP/extensions/GeoCrumbs/GeoCrumbs.php";
require_once "$IP/extensions/GeoData/GeoData.php";
require_once "$IP/extensions/ExternalData/ExternalData.php";
require_once "$IP/extensions/ParserFunctions/ParserFunctions.php";
require_once "$IP/extensions/MultimediaViewer/MultimediaViewer.php";
require_once "$IP/extensions/ApiSandbox/ApiSandbox.php";
require_once "$IP/extensions/OAuth/OAuth.php";

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
}

# Enable old string functions (needed at our semantic templates)
require_once "$IP/extensions/ParserFunctions/ParserFunctions.php";
$wgPFEnableStringFunctions = true;

# Interwiki links (nomadwiki, trashwiki etc)
# - Grant sysops permissions to edit interwiki data
# - To enable pulling global interwikis from a central database
#require_once "$IP/extensions/Interwiki/Interwiki.php";
#$wgGroupPermissions['sysop']['interwiki'] = true;
#$wgInterwikiCentralDB = 'interwiki';

# Recent changes cleanup
# https://www.mediawiki.org/wiki/Extension:Recent_Changes_Cleanup
require_once "$IP/extensions/RecentChangesCleanup/RecentChangesCleanup.php";
$wgAvailableRights[] = 'recentchangescleanup';
$wgGroupPermissions['sysop']['recentchangescleanup'] = true;
$wgGroupPermissions['recentchangescleanup']['recentchangescleanup'] = true;

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

# Echo
# https://www.mediawiki.org/wiki/Extension:Echo
#require_once "$IP/extensions/Echo/Echo.php";
$wgEchoAgentBlacklist = array( 'Hitchbot', 'Hitchwiki' );

# Adds some features into Vector theme
# https://www.mediawiki.org/wiki/Extension:VectorBeta
require_once "$IP/extensions/BetaFeatures/BetaFeatures.php";
require_once "$IP/extensions/VectorBeta/VectorBeta.php";
require_once "$IP/extensions/BetaFeatureEverywhere/BetaFeatureEverywhere.php";
$wgDefaultUserOptions['betafeatures-vector-compact-personal-bar'] = '0';
$wgDefaultUserOptions['betafeatures-vector-typography-update'] = '1';
$wgDefaultUserOptions['betafeatures-vector-fixedheader'] = '1';
$wgVectorBetaTypography = true;
$wgVectorBetaPersonalBar = true;
$wgVectorBetaWinter = true;

# Enables some features required by VectorBeta such as Special:MobileMenu
# https://www.mediawiki.org/wiki/Extension:MobileFrontend
require_once "$IP/extensions/Mantle/Mantle.php"; // MobileFrontend requires Mantle
require_once "$IP/extensions/MobileFrontend/MobileFrontend.php";
$wgMFAutodetectMobileView = true;
$wgMobileFrontendLogo = $wgScriptPath . "/../wiki-mobilelogo.png"; // Should be 35 × 22 px

# EventLogging
# Required by $wgVectorBetaPersonalBar
# https://www.mediawiki.org/wiki/Extension:EventLogging
require_once "$IP/extensions/EventLogging/EventLogging.php";
$wgEventLoggingBaseUri = 'http://'.$hwConfig["general"]["domain"].':8080/event.gif';
$wgEventLoggingFile = "{$logDir}/events.log";

# UploadWizard
# https://www.mediawiki.org/wiki/Extension:UploadWizard
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


#
# Hitchwiki extensions
#
require_once "$IP/extensions/HitchwikiVector/HitchwikiVector.php";
require_once "$IP/extensions/HWMap/HWMap.php";
require_once "$IP/extensions/HWWaitingTime/HWWaitingTime.php";
require_once "$IP/extensions/HWRatings/HWRatings.php";
require_once "$IP/extensions/HWComments/HWComments.php";

#
# Settings for preventing spam on MediaWiki
#
if($hwConfig["spam"]["spamprotection"]) {
  require_once "mediawiki-spam.php";
}
