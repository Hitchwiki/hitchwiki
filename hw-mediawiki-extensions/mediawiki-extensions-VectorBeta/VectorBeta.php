<?php

if ( function_exists( 'wfLoadExtension' ) ) {
	wfLoadExtension( 'HWVectorBeta' );
	// Keep i18n globals so mergeMessageFileList.php doesn't break
	$wgMessagesDirs['VectorBeta'] = __DIR__ . '/i18n';
	/* wfWarn(
		'Deprecated PHP entry point used for VectorBeta extension. Please use wfLoadExtension instead, ' .
		'see https://www.mediawiki.org/wiki/Extension_registration for more details.'
	); */
	return true;
} else {
	die( 'This version of the HWVectorBeta extension requires MediaWiki 1.25+' );
}
