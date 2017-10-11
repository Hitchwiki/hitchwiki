<?php

$wgExtensionCredits['HWComments'][] = array(
  'path' => __FILE__,
  'name' => 'HWComments',
  'author' => array('Rémi Claude', 'Mikael Korpela', 'Olexandr Melnyk'),
  'url' => 'https://github.com/Hitchwiki/HWComments-extension',
  'version' => '1.0.0',
  "authors" => "http://hitchwiki.org"
);

$dir = __DIR__;

//Database hook
$wgAutoloadClasses['HWCommentsHooks'] = "$dir/HWCommentsHooks.php";
$wgHooks['LoadExtensionSchemaUpdates'][] = 'HWCommentsHooks::onLoadExtensionSchemaUpdates';

//Deletion and undeletion hooks
$wgHooks['ArticleDeleteComplete'][] = 'HWCommentsHooks::onArticleDeleteComplete';
$wgHooks['ArticleRevisionUndeleted'][] = 'HWCommentsHooks::onArticleRevisionUndeleted';

//APIs
$wgAutoloadClasses['HWCommentsBaseApi'] = "$dir/api/HWCommentsBaseApi.php";
$wgAutoloadClasses['HWAddCommentApi'] = "$dir/api/HWAddCommentApi.php";
$wgAutoloadClasses['HWDeleteCommentApi'] = "$dir/api/HWDeleteCommentApi.php";
$wgAutoloadClasses['HWGetCommentsApi'] = "$dir/api/HWGetCommentsApi.php";
$wgAutoloadClasses['HWGetCommentsCountApi'] = "$dir/api/HWGetCommentsCountApi.php";
$wgAPIModules['hwaddcomment'] = 'HWAddCommentApi';
$wgAPIModules['hwdeletecomment'] = 'HWDeleteCommentApi';
$wgAPIModules['hwgetcomments'] = 'HWGetCommentsApi';
$wgAPIModules['hwgetcommentscount'] = 'HWGetCommentsCountApi';

return true;
