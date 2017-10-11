// Modify languages menu
( function ( mw, $ ) {

  if(mw.config.get('wgAction') == 'view') {

    // Languages list at the sidebar
    // Produced by `LANGUAGES` at `/scripts/pages/MediaWiki:Sidebar`
    $languagesPortal = $('#p-lang');

    if($languagesPortal.length) {

      // Grab languages list
      $languages = $languagesPortal.find('ul').addClass('hw-interwiki');

      // Get Trustroots & BeWelcome links
      var $hospexLinksContainer = $('#hw-hospex');

      // if we have hospex links, append them to the list
      if ($hospexLinksContainer.length) {

        var $hospexLinks = $hospexLinksContainer.find('li');

        if ($hospexLinks.length) {
          $hospexLinks.each(function(index, element) {
            $languages.prepend(element);
          });
        }
        // Remove hospex links from the article
        $hospexLinksContainer.remove();
      }

      // Add languages under the main title on other pages except main page
      if(mw.config.get('wgPageName') !== 'Main_Page') {
        $languages.insertAfter('#firstHeading');
      }

      // Remove languages list from the sidebar
      $languagesPortal.remove();

      // Highlight users own language
      if(mw.config.exists('wgUserLanguage')) {
        $languages.find( '.interwiki-' + mw.config.get('wgUserLanguage') ).addClass('hw-userlang');
      }

    }

  }

}( mediaWiki, jQuery ) );
