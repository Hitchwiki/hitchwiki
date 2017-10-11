<?php
/*
 * The rating map for country special page
 * Can be accessed on [[Special:HWRatings]]
 */
class SpecialRatingsMap extends SpecialPage {
  function __construct() {
    parent::__construct( 'HWCountries' );
  }

  function execute( $par ) {
    $output = $this->getOutput();
    $output->setPageTitle( 'Hitchwiki Ratings Countries Map' );
    $output->isPrintable(false);
    $output->addModules( 'ext.HWRatings' );

    // The Map
    $output->addHTML('<div id="hw-ratings-map"></div>');

  }
}
