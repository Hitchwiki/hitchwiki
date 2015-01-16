<?php
/*
 * Settings for preventing spam on MediaWiki
 *
 * See also
 * - https://github.com/guaka/hitchwiki/issues/104
 * - https://github.com/Hitchwiki/hitchwiki-private/issues/85
 *
 * Wikipedia setup for inspiration: https://en.wikipedia.org/wiki/Special:Version#sv-credits-antispam
 */

$wgNoFollowLinks     = true;

/*
 * EMERGENCY LOCKS
 */
# Disable sign up form at MW - prevents new user registrations except by sysops
//$wgGroupPermissions['*']['createaccount'] = false;

/*
* - "Drop in and forget" -extensions
* - Simple settings
*/
// https://www.mediawiki.org/wiki/Extension:SpamBlacklist
require_once("{$IP}/extensions/SpamBlacklist/SpamBlacklist.php");
// https://www.mediawiki.org/wiki/Extension:TorBlock — Sorry, Tor users!
require_once("{$IP}/extensions/TorBlock/TorBlock.php");
// Require email confirmations to edit articles
$wgEmailConfirmToEdit = true;
// No editing for anonymous
$wgGroupPermissions['*']['edit'] = false;
// Allow only certain users to post urls
$wgAutopromote["advanced"] = array(APCOND_EDITCOUNT, 1);
$wgAutoConfirmAge = 60*60*24;
$wgAutoConfirmCount = 1;

/*
 * StopForumSpam
 * https://www.mediawiki.org/wiki/Extension:StopForumSpam
 */
if( !empty($hwConfig["spam"]["stopforumspamkey"]) ) {
  require_once "$IP/extensions/StopForumSpam/StopForumSpam.php";
  $wgSFSAPIKey = $hwConfig["general"]["stopforumspamkey"];
  $wgSFSIPListLocation = "";
}

/*
 * ConfirmEdit
 * https://www.mediawiki.org/wiki/Extension:ConfirmEdit
 */
require_once("{$IP}/extensions/ConfirmEdit/ConfirmEdit.php");
$wgCaptchaTriggers['edit']          = false;
$wgCaptchaTriggers['create']        = false;
$wgCaptchaTriggers['addurl']        = true;
$wgCaptchaTriggers['createaccount'] = true;
$wgCaptchaTriggers['badlogin']      = true;
$wgCaptchaTriggersOnNamespace[NS_TALK]['addurl'] = false;
//$wgCaptchaTriggersOnNamespace[NS_PROJECT]['edit'] = false;

/*
 * ConfirmEdit - QuestyCaptcha
 * http://www.mediawiki.org/wiki/Extension:ConfirmEdit#QuestyCaptcha
 */
 /*
 require_once "$IP/extensions/ConfirmEdit/QuestyCaptcha.php";
 $wgCaptchaClass = 'QuestyCaptcha';
 $arr = array (
   'Which finger is used for hitchhiking?' => "thumb",
   'What is driver usually driving on the road?' => "car",
   'What is the bright color on top of this page? (Starts with "y".)' => "yellow",
   //  "What is this wiki's name?" => "$wgSitename",
   //  'Please write the magic secret, "passion", here:' => 'passion',
   //  'Type the code word, 567, here:' => '567',
   //  'Which animal? <img src="http://www.example.com/path/to/filename_not_including_dog.jpg" alt="" title="" />' => 'dog',
);
foreach ( $arr as $key => $value ) {
  $wgCaptchaQuestions[] = array( 'question' => $key, 'answer' => $value );
}
*/

/*
 * ConfirmEdit - ReCaptcha
 * http://www.mediawiki.org/wiki/Extension:ConfirmEdit#ReCaptcha
 */
if( !empty($hwConfig["spam"]["recaptchapublickey"]) && !empty($hwConfig["spam"]["recaptchaprivatekey"]) ) {
   require_once("{$IP}/extensions/ConfirmEdit/ReCaptcha.php");
   $wgCaptchaClass = 'ReCaptcha';
   $wgReCaptchaPublicKey = $hwConfig["general"]["recaptchapublickey"];
   $wgReCaptchaPrivateKey = $hwConfig["general"]["recaptchaprivatekey"];
}

/*
 * Honeypots/blacklisting
 */
// http://www.mediawiki.org/wiki/Manual:Combating_spam#Honeypots.2C_DNS_BL.27s_and_HTTP_BL.27s
$wgEnableSorbs = true;
$wgSorbsURL =  'http.dnsbl.sorbs.net.';
// makes saving an edited page slower, but should keep out considerable amount of spam
$wgSpamRegexGroup['*'] = "/https?|viagra|porn|phentermine|free-resumes|playmate|erotic|valium|xanax|FIELD.(OTHER|MESSAGE)|babacar|display\s*:none|overflow\s*:auto/i";
$wgSpamRegexGroup['sysop'] = '';
$wgSpamRegexGroup['bureaucrat'] = '';
$wgSpamRegexGroup['autoconfirmed'] = '/viagra|porn/';

$wgEnableDnsBlacklist = true;
$wgDnsBlacklistUrls = array( 'xbl.spamhaus.org', 'opm.tornevall.org' );

/*
 * Mass delete pages with Nuke
 */
require_once "$IP/extensions/Nuke/Nuke.php";

/*
 * Locking out spambots.
 * This might also affect some users, but it's still better than disabling registering completely
 */
$browserBlacklist = array(
  'Mozilla/5.0 (Windows; U; Windows NT 5.1; en-US; rv:1.9.2.10) Gecko/20100914 Firefox/3.6.10',
  'Mozilla/5.0 (Windows; U; Windows NT 5.2; en-US)'
);
