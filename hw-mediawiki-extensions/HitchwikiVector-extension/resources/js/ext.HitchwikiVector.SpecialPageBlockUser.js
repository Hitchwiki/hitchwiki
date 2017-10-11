/*
 * Pre-select our common block-settings
 * https://github.com/Hitchwiki/hitchwiki/issues/23
 */
( function ( mw, $ ) {

  $( function () {
    if ( mw.config.exists('wgCanonicalSpecialPageName') && mw.config.get('wgCanonicalSpecialPageName') == 'block' ) {
      $('#mw-input-wpDisableEmail').prop('checked', true);
      $('#mw-input-wpHardBlock').prop('checked', true);
      $('#mw-input-wpExpiry').val('infinite');
    }
  } );

}( mediaWiki, jQuery ) );
