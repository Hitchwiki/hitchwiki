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

# Path for storing sessions
# https://secure.php.net/manual/en/function.session-save-path.php
# https://secure.php.net/manual/en/session.configuration.php
session_save_path( isset($hwConfig['session_save_path']) ? $hwConfig['session_save_path'] : $IP . '../../tmp/sessions' );

# Load Hitchwiki Config
require_once '{{ dir.spyc }}';
if (!function_exists('spyc_load_file')) {
  die('Missing `mustangostang/spyc`!');
}
$hwConfig = spyc_load_file('{{ dir.settings }}');

if ($wgCommandLineMode) {
  if (isset($_SERVER) && array_key_exists( 'REQUEST_METHOD', $_SERVER))
  die("This script must be run from the command line\n");
} elseif (empty($wgNoOutputBuffer)) {
  // Compress output if the browser supports it
  if (!ini_get( 'zlib.output_compression')) @ob_start('ob_gzhandler');
}

# Pick a random Geonames account username to be used for this page load
# We're doing this to avoid request throttling especially during migration,
# as Geonames API has 2000 req / hour limit

if (array_key_exists('geonames', $hwConfig["mediawiki"])) {
  $hwConfig['mediawiki']['geonames']['username'] = $hwConfig['mediawiki']['geonames']['usernames'][array_rand($hwConfig['mediawiki']['geonames']['usernames'])];
}

# Uncomment this to disable output compression
# $wgDisableOutputCompression = true;

$wgSitename = '{{ mediawiki.sitename }}';
$wgMetaNamespace = '{{ mediawiki.metanamespace }}';

##
# Dev environment settings
##
$hwDebug = {{ mediawiki.debug }};
$hwCache = {{ mediawiki.cache }};

# Enable debugging only on dev environment
if ($hwDebug) {

  // Enable error reporting
  error_reporting( -1 );
  ini_set( 'display_errors', 1 );

  // Show the debug toolbar if `hw_debug` is set on the request,
  // either as a parameter or a cookie.
  // https://www.mediawiki.org/wiki/Debugging_toolbar
  if ( !empty( $_REQUEST['hw_debug'] ) ) {
    $wgDebugToolbar = true;
  }
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
$logDir = '{{ dir.log }}';
$wgDebugLogFile = "{$logDir}/mediawiki-debug.log";
foreach ( array( 'exception', 'runJobs', 'JobQueueRedis' ) as $logGroup ) {
  $wgDebugLogGroups[$logGroup] = "{$logDir}/mediawiki-{$logGroup}.log";
}

# Setup `$hwLang`
# Will also change $wgSitename if it finds local name
require_once('{{ dir.conf }}/mediawiki-lang.php');

# When you make changes to this configuration file, this will make
# sure that cached pages are cleared.
$configdate      = gmdate( 'YmdHis', @filemtime( __FILE__ ) );
$wgCacheEpoch    = max($wgCacheEpoch, $configdate);

# The URL base path to the directory containing the wiki;
# defaults for all runtime URL paths are based off of this.
# For more information on customizing the URLs
# (like /w/index.php/Page_title to /wiki/Page_title) please see:
# https://www.mediawiki.org/wiki/Manual:Short_URL
$wgScriptPath       = '/'  . $hwLang;
$wgScriptExtension  = '.php';
$wgArticlePath      = "{$wgScriptPath}/$1";
$wgArticlePath      = str_replace('//', '/', $wgArticlePath);
$wgScript           = "{$wgScriptPath}/index.php";
$wgScript           = str_replace('//', '/', $wgScript);
$wgUsePathInfo      = true;
$wgCookieDomain     = '{{ cookiedomain }}';

# Site language code, should be one of the list in ./languages/Names.php
$wgLanguageCode = $hwLang;

# The protocol and server name to use in fully-qualified URLs
##
# Since 1.18 MediaWiki also supports setting `$wgServer` to a protocol-relative
# URL (e.g., //www.mediawiki.org). This is used for supporting both
# HTTP and HTTPS with the same caches by using links that work under both
# protocols. When doing this, `$wgCanonicalServer` can be used to set the
# full URL including protocol that will be used in locations such as emails
# that don't support protocol relative URLs.
##
# https://www.mediawiki.org/wiki/Manual:$wgServer
# https://www.mediawiki.org/wiki/Manual:$wgCanonicalServer
$wgServer = '//{{ domain }}';
$wgCanonicalServer = '{{ mediawiki.protocol }}://{{ domain }}';

# If enabled with "true", output a `<link rel="canonical">`
# tag on every page indicating the canonical server which should be used.
$wgEnableCanonicalServerLink = true;

# The relative URL path to the skins directory
$wgStylePath = $wgScriptPath . '/skins';

# The relative URL path to the logo and icons
$wgLogo = $wgScriptPath . '/../wiki-logo.png';
$wgAppleTouchIcon = $wgScriptPath . '/../apple-touch-icon.png';
$wgFavicon = $wgScriptPath . '/../favicon.png';

# UPO means: this is also a user preference option

$wgEnableEmail = true;
$wgEnableUserEmail = {{ mediawiki.enableuseremail }};

$wgEmergencyContact = 'contact@{{ domain }}';
$wgPasswordSender = 'noreply@{{ domain }}';

# For a detailed description of the following switches see
# http://meta.wikimedia.org/Enotif and http://meta.wikimedia.org/Eauthent
# There are many more options for fine tuning available see
# /includes/DefaultSettings.php
# UPO means: this is also a user preference option
$wgEnotifUserTalk            = true; // UPO
$wgEnotifWatchlist           = true; // UPO
$wgEmailAuthentication       = true;
$wgEnotifRevealEditorAddress = false;
$wgEnotifFromEditor          = false;

# Use SMTP to send out emails
# https://www.mediawiki.org/wiki/Manual:$wgSMTP
if ({{ smtp.enabled }}) {
  $wgSMTP = array(
    'host'     => '{{ smtp.host }}',      // could also be an IP address. Where the SMTP server is located
    'IDHost'   => '{{ domain }}', // Generally this will be the domain name of your website (aka mywiki.org)
    'port'     => '{{ smtp.port }}',      // Port to use when connecting to the SMTP server
    'auth'     => '{{ smtp.auth }}',      // Should we use SMTP authentication (true or false)
    'username' => '{{ smtp.username }}',  // Username to use for SMTP authentication (if being used)
    'password' => '{{ smtp.password }}'   // Password to use for SMTP authentication (if being used)
  );
}

# Database settings
$wgDBtype     = "mysql";
$wgDBserver   = '{{ mediawiki.db.host }}';
$wgDBname     = '{{ mediawiki.db.database }}';
$wgDBuser     = '{{ mediawiki.db.username }}';
$wgDBpassword = '{{ mediawiki.db.password }}';

# Shared database settings
# Mainly for Users and Interwiki extension
# By default shares 'users' and 'user_properties' tables
$wgSharedDB = '{{ mediawiki.db.database }}';
$wgSharedSchema = false;
$wgSharedPrefix = '{{ mediawiki.db.prefix }}';
# https://www.mediawiki.org/wiki/Manual:Shared_database#The_user_groups_table
$wgSharedTables[] = 'user_groups';

# MySQL specific settings
$wgDBprefix = '{{ mediawiki.db.prefix }}';

# MySQL table options to use during installation or update
$wgDBTableOptions = 'ENGINE=InnoDB, DEFAULT CHARSET=binary';

# Experimental charset support for MySQL 5.0.
$wgDBmysql5 = false;

# Basic MW caching
$wgEnableParserCache = $hwCache;
$wgCachePages = $hwCache;
$wgResourceLoaderMaxage['unversioned'] = array(
	'server' => $hwCache ? 30 : 0, // minutes
	'client' => $hwCache ? 30 : 0, // minutes
);

# Shared memory settings
# https://www.mediawiki.org/wiki/Manual:$wgMainCacheType
# https://www.mediawiki.org/wiki/Memcached
if ($hwCache) {
  $wgMemCachedPersistent = false;
  $wgUseMemCached = true;
  $wgMainCacheType = CACHE_MEMCACHED;
  $wgParserCacheType = CACHE_MEMCACHED;
  $wgMemCachedTimeout = 5000000;
  $wgMemCachedInstanceSize = 2000;
  $wgMemCachedServers = array('127.0.0.1:11211');
}
else {
  $wgMainCacheType = CACHE_NONE;
}


$wgExtraLanguageNames['nomad'] = 'Nomadwiki';
$wgExtraLanguageNames['trash'] = 'Trashwiki';
$wgExtraLanguageNames['wikipedia'] = 'Wikipedia';
$wgExtraLanguageNames['wikivoyage'] = 'Wikivoyage';
$wgExtraLanguageNames['trustroots'] = 'Trustroots';
$wgExtraLanguageNames['bewelcome'] = 'BeWelcome';

# To enable image uploads, make sure the 'images' directory
# is writable, then set this to true:
# ImageMagick is required by UploadWizard extension
$wgEnableUploads = true;
$wgUseImageMagick = true;
$wgImageMagickConvertCommand = '/usr/bin/convert';

# To enable image uploads, make sure the 'images' directory
# is writable, then set this to true:
$wgEnableUploads = true;
$wgGenerateThumbnailOnParse = false;

$wgUploadPath       = $wgScriptPath . '/images/' . $hwLang;
$wgUploadDirectory  = $IP . '/images/' . $hwLang;

if ($hwLang != 'en') {
  // $wgUseSharedUploads            = true;
  $wgSharedUploadPath            = $wgUploadPath;
  $wgSharedUploadDirectory       = $wgUploadDirectory;
  $wgHashedSharedUploadDirectory = true;
  $wgSharedUploadDBname          = '{{ mediawiki.db.database }}';
}

# Allowed file extensions for uploading files
$wgFileExtensions = array(
  'png', 'gif', 'jpg', 'jpeg', 'svg', 'pdf',
  'PNG', 'GIF', 'JPG', 'JPEG', 'SVG', 'PDF',
);

$wgUseCommaCount = false;

# InstantCommons allows wiki to use images from http://commons.wikimedia.org
$wgUseInstantCommons = true;

# If you use ImageMagick (or any other shell command) on a
# Linux server, this will need to be set to the name of an
# available UTF-8 locale
$wgShellLocale = 'en_US.utf8';

# If you want to use image uploads under safe mode,
# create the directories images/archive, images/thumb and
# images/temp, and make them all writable. Then uncomment
# this, if it's not already uncommented:
#$wgHashedUploadDirectory = false;

# Set $wgCacheDirectory to a writable directory on the web server
# to make your wiki go slightly faster. The directory should not
# be publically accessible from the web.
$wgCacheDirectory = "$IP/cache";

$wgSecretKey = '{{ mediawiki.secretkey }}';

# Site upgrade key. Must be set to a string (default provided) to turn on the
# web installer while LocalSettings.php is in place
$wgUpgradeKey = '{{ mediawiki.upgradekey }}';

# For attaching licensing metadata to pages, and displaying an
# appropriate copyright notice / icon. GNU Free Documentation
# License and Creative Commons licenses are supported so far.

$wgEnableCreativeCommonsRdf = true;
$wgRightsPage               = ''; // Set to the title of a wiki page that describes your license/copyright
$wgRightsUrl                = 'http://creativecommons.org/licenses/by-sa/4.0/';
$wgRightsText               = 'Creative Commons Attribution-Share Alike';
$wgRightsIcon               = $wgStylePath . '/common/images/cc-by-sa.png';


$wgAllowDisplayTitle = true;

# CSS
$wgUseSiteCss = true;
$wgAllowUserCss = true;

# Path to the GNU diff3 utility. Used for conflict resolution.
$wgDiff3 = '/usr/bin/diff3';

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

// Disable creating users via API
$wgAPIModules['createaccount'] = 'ApiDisabled';

/***** Vector skin ******************************************************************************************/

# Hitchwiki is largely relying on Vector skin so other skins are
# not even included. We also have a few extensions expanding functionality and
# look, see "HitchwikiVector" and "HWVectorBeta" from `/extensions` folder.

# Default skin. Use the internal symbolic.
$wgDefaultSkin = 'vector';

wfLoadSkin('Vector');

# Search form look.
# true = use an icon search button
# false = use Go & Search buttons
$wgVectorUseSimpleSearch = true;

# Watch and unwatch as an icon rather than a link.
# true = use an icon watch/unwatch button
# false = use watch/unwatch text link
$wgVectorUseIconWatch = true;

# Experimental setting to make Vector slightly more responsive. Not ready for production purposes and false by default.
# true = Use responsiveness to improve usability in narrow viewports
# false = No responsiveness
$wgVectorResponsive = false;


/***** Extensions ******************************************************************************************/

# Settings for MediaWiki extensions
require_once '{{ dir.conf }}/mediawiki-extensions.php';


# Settings for preventing spam on MediaWiki
# You can turn these on/off from `/configs/settings.yml`
if ({{ mediawiki.spam.spamprotection }}) {
  require_once '{{ dir.conf }}/{{ dir.conf }}/mediawiki-spam.php';
}


/***** CLI * Settings when running in command line mode ****************************************************/

if ($wgCommandLineMode) {
  if (isset($_SERVER) && array_key_exists('REQUEST_METHOD', $_SERVER)) {
    die("This script must be run from the command line\n");
  }

  /**
   * Temporarity clear out shared tables when running `maintenance/update.php`
   *
   * As of Mediawiki 1.21, `$wgSharedTables` must be temporarily cleared during
   * upgrade. Otherwise, the shared tables are not touched at all (neither tables
   * with `$wgSharedPrefix`, nor those with `$wgDBprefix`), which may lead to
   * failed upgrade.
   * https://www.mediawiki.org/wiki/Manual:$wgSharedTables#Upgrading
   */
  $wgSharedTables = array();
}
