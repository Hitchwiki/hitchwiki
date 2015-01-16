"use strict";
/*
 * This is configuration file for Parsoid, copied from settings.js
 *
 * Also see the file ParserService.js for more information.
 */

exports.setup = function( parsoidConfig ) {
        // The URL of your MediaWiki API endpoint
        //
        // We pre-define wikipedias as 'enwiki', 'dewiki' etc. Similarly for
        // other projects: 'enwiktionary', 'enwikiquote', 'enwikibooks',
        // 'enwikivoyage' etc.
        //
        // Optionally, you can also pass in a proxy specific to this prefix
        // (overrides defaultAPIProxyURI), or null to disable proxying for
        // this end point.
        parsoidConfig.setInterwiki( 'hitchwiki.dev', 'http://hitchwiki.dev/en/api.php' );

        // A default proxy to connect to the API endpoints. Default: undefined
        // (no proxying). Overridden by per-wiki proxy config in setInterwiki.
        // parsoidConfig.defaultAPIProxyURI = 'http://proxy.example.org:8080';

        // Enable debug mode (prints extra debugging messages)
        // parsoidConfig.debug = true;

        // Use the PHP preprocessor to expand templates via the MW API (default true)
        //parsoidConfig.usePHPPreProcessor = false;

        // Use selective serialization (default false)
        parsoidConfig.useSelser = true;

        // allow cross-domain requests to the API (default disallowed)
        //parsoidConfig.allowCORS = '*';
};
