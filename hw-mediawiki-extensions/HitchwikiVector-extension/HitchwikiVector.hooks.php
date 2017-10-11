<?php

class HitchwikiVectorHooks {

  /**
   * Handler for BeforePageDisplay
   * @param OutputPage $out
   * @param Skin $skin
   * @return bool
   */
  static function onBeforePageDisplay( &$out, &$skin ) {
    // Ensure Hitchwiki skin runs only against Vector skin
    // FIXME: See bug 62897
    if ( $skin->getSkinName() !== 'vector' ) {
      return true;
    }

    // Add our modules
    $modules = array(
      'skins.vector.hitchwiki'
    );
    $out->addModules( $modules );

    return true;
  }

  /**
  * Disable powered by footer icons
  * Handled at hook BeforePageDisplay
  * @param OutputPage $out
  * @param Skin $skin
  * @return bool
  */
  static function modifyFooterIcons( &$out, &$skin ) {
    global $wgFooterIcons;
    // Don't `unset()` these, as it would cause warning:
    // "PHP Notice:  Undefined index: copyright in /usr/share/webapps/mediawiki/includes/skins/Skin.php"
    // https://www.mediawiki.org/w/index.php?title=Topic:T81fd4ovtrvakxus&topic_showPostId=t81fd4oxdy9z16jo#flow-post-t81fd4oxdy9z16jo
    $wgFooterIcons["poweredby"] = null;
    $wgFooterIcons["copyright"] = null;
    return true;
  }

  /*
   * Hook into the parser to process <hw-languages> template tag
   *
   * Lists all the Hitchwiki network languages from $hwLangConfig global variable
   * https://www.mediawiki.org/wiki/Manual:Tag_extensions
   */
  static function languagesParserInit( Parser $parser ) {

    // When the parser sees the <hw-languages> tag, it executes
    // the hwLanguagesRender function (see below)
    //$parser->setHook( 'languages', 'HitchwikiVectorTagLanguages::languagesRender' );
    $HitchwikiVectorTagLanguages = new HitchwikiVectorTagLanguages();
    $parser->setHook( 'hw-languages', 'HitchwikiVectorTagLanguages::languagesRender' );

    // Always return true from this function. The return value does not denote
    // success or otherwise have meaning - it just must always be true.
    return true;
  }

}
