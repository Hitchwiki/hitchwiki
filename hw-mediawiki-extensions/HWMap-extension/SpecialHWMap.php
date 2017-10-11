<?php
/**
 * The main map special page
 * Can be accessed on [[Special:HWMap]]
 */
class SpecialHWMap extends SpecialPage {
  function __construct() {
    parent::__construct( 'HWMap' );
  }

  function execute( $parser ) {
    $output = $this->getOutput();
    $output->setPageTitle('Hitchwiki Map');
    $output->isPrintable(false);
    $output->addModules('ext.HWMap');

    // The Map
    $output->addHTML('<div class="hwmap-container"><div id="hwmap">');

    // Add new spot HTML
    // `class` variable is to fix bug caused by `ext.headertabs.core.js`:
    // `Uncaught TypeError: Cannot read property 'indexOf' of undefined at tabEditTabLink`
    $output->addHTML('<a href="#" id="hwmap-add" class="section-0" style="display:none;">' . wfMessage('hwmap-add-new-spot')->text() . '</a>');
    $output->addHTML('<div id="hwmap-add-wrap" style="display:none;">');
    $output->addHTML('<p>' . wfMessage('hwmap-adding-new-spot-marker-instruction')->text() . '</p>');



    // {{#autoedit:form=Flavor|target=Vanilla|link text=Vote for Vanilla|link type=link|query string=Flavor[Num votes]={{#expr:{{#show:Vanilla|?Has number of votes}} + 1}}|summary=Adding vote {{#expr:{{#show:Vanilla|?Has number of votes}} + 1}}. }}


    // Semantic form for adding new spot
    // https://www.mediawiki.org/wiki/Extension:Page_Forms/Linking_to_forms#Using_.23forminput
    // This array is going to be joined into one string
    /*
    $test = array(
      // The name of the SP form to be used
      'autoedit:form=Spot',

      // The size of the text input
      //'size=25',

      // Redirect to another page after form finishes saving
      //'target=Special:HWMap',

      'link type=button',

      // The text that will appear on the "submit" button
      'button text=autoedit', //. wfMessage('hwmap-continue')->text(),

      // `<unique number>` - by default, gets replaced by the lowest number
      // for which the page title that's generated is unique. Normally, this
      // value starts out as blank, then goes to 2, then 3, etc. However, one
      // can manually set the starting number for this value, by adding a
      // `start=` parameter; this number must be 0 or higher. For instance,
      // to have the number start at 1 and go upward, you should set the tag
      // to be `<unique number;start=1>`. You can also instead set it to be
      // a random six-digit number, by adding the `random` parameter, so that
      // the tag looks like `<unique number;random>`. You can also set the
      // number of digits to be something other than 6, by adding a number
      // after `random`, like `<unique number;random;4>`.
      // Note that the parameters in all these cases are
      // delimited by semicolons.
      //
      // Initially in 2017 we importet 30K spots from
      // the old (2008—2017) Hitchwiki Maps
      //
      // https://www.mediawiki.org/wiki/Extension:Page_Forms/Linking_to_forms#The_one-step_process
      'page name=Spot <unique number;start=30000>',

      //  you can use this option to pass information to the form
      'query string=Spot[Location]=23,23&Spot[Country]=Finland&Spot[Cities]=Helsinki',

    );

    $output->addWikiText('{{#' . implode('|', $test) . '}}');
    */



    // Semantic form for adding new spot
    // https://www.mediawiki.org/wiki/Extension:Page_Forms/Linking_to_forms#Using_.23forminput
    // This array is going to be joined into one string
    $newSpotFormVars = array(
      // The name of the SP form to be used
      'forminput:form=Spot',

      // The size of the text input
      //'size=25',

      // Redirect to another page after form finishes saving
      'returnto=Special:HWMap',

      // She starting value of the input
      'default value=',

      // The text that will appear on the "submit" button
      'button text=' . wfMessage('hwmap-continue')->text(),

      // `<unique number>` - by default, gets replaced by the lowest number
      // for which the page title that's generated is unique. Normally, this
      // value starts out as blank, then goes to 2, then 3, etc. However, one
      // can manually set the starting number for this value, by adding a
      // `start=` parameter; this number must be 0 or higher. For instance,
      // to have the number start at 1 and go upward, you should set the tag
      // to be `<unique number;start=1>`. You can also instead set it to be
      // a random six-digit number, by adding the `random` parameter, so that
      // the tag looks like `<unique number;random>`. You can also set the
      // number of digits to be something other than 6, by adding a number
      // after `random`, like `<unique number;random;4>`.
      // Note that the parameters in all these cases are
      // delimited by semicolons.
      //
      // Initially in 2017 we importet 30K spots from
      // the old (2008—2017) Hitchwiki Maps
      //
      // https://www.mediawiki.org/wiki/Extension:Page_Forms/Linking_to_forms#The_one-step_process
      'page name=Spot <unique number;start=30000>',

      //  you can use this option to pass information to the form
      'query string=Spot[Location]=0,0&Spot[Country]=&Spot[Cities]=',

      // Opens the form in a popup window
      // Note: popup forms may not work if you have the ConfirmEdit extension
      // installed - users might not see the CAPTCHA they need to fill out.)
      //'popup'
    );

    $output->addWikiText('{{#' . implode('|', $newSpotFormVars) . '}}');

    // More add new spot HTML...
    $output->addHTML('<a href="#" id="hwmap-cancel-adding">' . wfMessage('hwmap-cancel')->text() . '</a>');
    $output->addHTML('</div><!--#hwmap-add-wrap-->');
    $output->addHTML('</div></div>');


    // Variables for the SemanticPages form for editing spots
    $editSpotFormVars = array(
      // the name of the SemanticPages form to be used
      'forminput:form=Spot',
      //'size=',
      'default value=',
      'returnto=Special:HWMap',
      'button text=' . wfMessage('hwmap-continue')->text(),
      'page name=',
      'query string=Spot[Location]=&Spot[Country]=&Spot[Cities]=',
      'popup'
    );

    // Semantic form for editing new spot
    $output->addWikiText('<div id="hw-spot-edit-form-wrap">{{#' . implode('|', $editSpotFormVars) . '}}</div>');

    // The spot
    $output->addHTML('<div id="hw-specialpage-spot"></div>');

    // The zoom info overlay
    // Toggled visible on high zoom levels
    $output->addHTML('<div id="hw-zoom-info-overlay">' . wfMessage('hwmap-zoom-closer-to-see-spots')->text() . '</div>');

  }
}
