<?php
class HWCountryRatingsApi extends ApiBase {
  public function execute() {

    $dbr = wfGetDB(DB_SLAVE);

    // Query the database
    $res = $dbr->select(
      array('hw_ratings_avg', 'categorylinks', 'page'),
      array('hw_page_id', 'hw_average_rating', 'cl_to', 'page_title'),
      array(),
      __METHOD__,
      array(),
      array(
        'categorylinks' => array(
          'JOIN',
          array('hw_page_id=cl_from AND cl_to = \'Countries\'')
        ),
        'page' => array(
          'LEFT JOIN ',
          array('hw_page_id=page_id')
        ),
      )
    );

    // Build the api result
    foreach( $res as $row ) {
      $vals = array(
        'id' => $row->hw_page_id,
        'title' => $row->page_title,
        'average_rating' => $row->hw_average_rating
      );
      $this->getResult()->addValue( array( 'query', 'spots' ), null, $vals );
    }

    return true;
  }

  // API endpoint description
  public function getDescription() {
    return 'Get average ratings of all the country page';
  }

}
