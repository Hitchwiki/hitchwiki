<?php

/**
 * Supported algorithms for the calculation of average waiting times
 */

define('WAITING_TIME_AVG_ALGORITHM_MEAN', 1);
define('WAITING_TIME_AVG_ALGORITHM_MEDIAN', 2);

/**
 * Algorithm to be used for the calculation of average waiting times
 */

$wgWaitingTimeAvgAlgorithm = WAITING_TIME_AVG_ALGORITHM_MEDIAN;

/**
 * Default waiting time distribution range settings (have to be in strictly ascending order!)
 */

$wgHwWaitingTimeRangeBounds = array(
	0, // minimum allowed waiting time (inclusive)
	15, // [0; 15] minute range
	30, // (15; 30] minute range
	60, // (30; 60] minute range
	9999 // (60 minutes; ~1 week] range; also maximum allowed waiting time (inclusive)
);

/* ------------------------------------------------------------------------ */

$wgExtensionCredits['api'][] = array(
	'path' => __FILE__,
	'name' => 'HWWaitingTime',
	'version' => '0.0.1',
  'author' => array('Rémi Claude', 'Mikael Korpela', 'Olexandr Melnyk'),
  'url' => 'https://github.com/Hitchwiki/HWWaitingTime-extension'
);

$dir = __DIR__;

$wgAutoloadClasses['HWWaitingTimeHooks'] = "$dir/HWWaitingTimeHooks.php";
$wgHooks['LoadExtensionSchemaUpdates'][] = 'HWWaitingTimeHooks::onLoadExtensionSchemaUpdates';

//Deletion and undeletion hooks
$wgHooks['ArticleDeleteComplete'][] = 'HWWaitingTimeHooks::onArticleDeleteComplete';
$wgHooks['ArticleRevisionUndeleted'][] = 'HWWaitingTimeHooks::onArticleRevisionUndeleted';

$wgAutoloadClasses['HWWaitingTimeBaseApi'] = "$dir/api/HWWaitingTimeBaseApi.php";
$wgAutoloadClasses['HWAddWaitingTimeApi'] = "$dir/api/HWAddWaitingTimeApi.php";
$wgAutoloadClasses['HWDeleteWaitingTimeApi'] = "$dir/api/HWDeleteWaitingTimeApi.php";
$wgAutoloadClasses['HWAvgWaitingTimeApi'] = "$dir/api/HWAvgWaitingTimeApi.php";
$wgAutoloadClasses['HWGetWaitingTimesApi'] = "$dir/api/HWGetWaitingTimesApi.php";
$wgAPIModules['hwaddwaitingtime'] = 'HWAddWaitingTimeApi';
$wgAPIModules['hwdeletewaitingtime'] = 'HWDeleteWaitingTimeApi';
$wgAPIModules['hwavgwaitingtime'] = 'HWAvgWaitingTimeApi';
$wgAPIModules['hwgetwaitingtimes'] = 'HWGetWaitingTimesApi';

return true;
