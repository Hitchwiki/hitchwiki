( function ( mw, $ ) {

  $( function () {

    // For some odd reason, these had fixed min-style:600px
    // That sucks. Removing it (they're handled at HitchwikiVector/resources/styles/forms.less instead)
    $('.sf-select2-container').attr('style', '');

    // Don't allow adding new content for non logged in users
    // wgUserId returns null when not logged in
    // Styles regarding this are under navigation.less
    if(mw.config.get('wgUserId')) {
      $('body').addClass('hw-user-logged');
    }
    else {
      $('body').addClass('hw-user-nonlogged');
    }

    // Move Special buttons to the footer at front page
    if(mw.config.get('wgPageName') === 'Main_Page') {
      $('#mw-page-actions').insertAfter('#mw-content-text');
      $('.mw-main-edit-button').insertAfter('#mw-content-text');
    }

  } );

}( mediaWiki, jQuery ) );
