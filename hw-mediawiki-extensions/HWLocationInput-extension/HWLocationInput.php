<?php

use HWLI\HookRegistry;

/**
 * @see https://github.com/Hitchwiki/HWLocationInput-extension
 *
 * @defgroup HWLocationInput Hitchwiki Location Input
 * @codeCoverageIgnore
 */
class HWLocationInput {

  /**
   * @since 1.0
   */
  public static function initExtension() {

    define( 'HWLI_VERSION', '1.0.0' );

    $GLOBALS['wgHWLICount'] = 0;
    $GLOBALS['wgHWLocationInput_debug'] = 1; // Debug on/off

    // Register resource files
    $GLOBALS['wgResourceModules']['ext.HWLocationInput.leaflet'] = array(
      'localBasePath' => __DIR__ ,
      'remoteExtPath' => 'HWLocationInput',
      'scripts' => array(
        'modules/vendor/leaflet/dist/leaflet.js',
      ),
      'styles' => array(
        'modules/vendor/leaflet/dist/leaflet.css',
      )
    );
    $GLOBALS['wgResourceModules']['ext.HWLocationInput'] = array(
      'localBasePath' => __DIR__ ,
      'remoteExtPath' => 'HWLocationInput',
      'position' => 'bottom',
      'scripts' => array(
        'modules/js/ext.HWLocationInput.js'
      ),
      'dependencies' => array(
        'ext.pageforms.main',
        'ext.HWLocationInput.leaflet'
      )
    );

  }

  /**
   * @since 1.0
   */
  public static function onExtensionFunction() {

    if ( !defined( 'PF_VERSION' ) ) {
      die( '<b>Error:</b><a href="https://github.com/SemanticMediaWiki/HWLocationInput/">Hitchwiki Location Input</a> requires the <a href="https://www.mediawiki.org/wiki/Extension:PageForms">Page Forms</a> extension. Please install and activate this extension first.' );
    }

    if ( isset( $GLOBALS['wgPageFormsFormPrinter'] )) {
      $GLOBALS['wgPageFormsFormPrinter']->setInputTypeHook( 'HW_Location', '\HWLI\HWLocationInput::init', array() );
    }
  }

  /**
   * @since 1.0
   *
   * @param string $dependency
   *
   * @return string|null
   */
  public static function getVersion( $dependency = null ) {

    if ( $dependency === null && defined( 'HWLI_VERSION' ) ) {
      return HWLI_VERSION;
    }

    if ( $dependency === 'PageForms' && defined( 'PF_VERSION' ) ) {
      return PF_VERSION;
    }

    return null;
  }

  /**
   * Expose config variables to JS frontend. Read them by:
   * ```
   * mw.config.get('keyname');
   * ```
   * Where keyname is e.g. `hwMapBoxUsername` or `hwDefaultCenter`.
   *
   * Set default value if config key doesn't exist:
   * ```
   * mw.config.get('keyname', 'defaultvalue');
   * ```
   *
   * https://www.mediawiki.org/wiki/Manual:Interface/JavaScript#mw.config
   *
   * @since 1.0
   *
   * @return boolean
   */
  public static function onResourceLoaderGetConfigVars( array &$vars ) {

    // Defined at MediaWiki config file
    global $hwMapboxUsername,
           $hwMapboxAccessToken,
           $hwMapboxMapkeyStreets,
           $hwDefaultCenter,
           $hwDefaultZoom;

    // MapBox config
    $vars['hwLocationInputMapboxUsername'] = $hwMapboxUsername ? $hwMapboxUsername : false;
    $vars['hwLocationInputMapboxAccessToken'] = $hwMapboxAccessToken ? $hwMapboxAccessToken : false;
    $vars['hwLocationInputMapboxMapkeyStreets'] = $hwMapboxMapkeyStreets ? $hwMapboxMapkeyStreets : false;

    // Default center for maps (Europe)
    // `[(float) latitude, (float) longitude]`
    $vars['hwLocationInputDefaultCenter'] = $hwDefaultCenter ? $hwDefaultCenter : array(48.6908333333, 9.14055555556);

    // Default zoom for maps (integer 1-22)
    $vars['hwLocationInputDefaultZoom'] = $hwDefaultZoom ? $hwDefaultZoom : 5;

    return true;
  }

}
