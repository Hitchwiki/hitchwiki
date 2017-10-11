<?php

class HWGetRatingsApi extends HWRatingsBaseApi {
  public function execute() {
    global $wgHwRatingsMinRating, $wgHwRatingsMaxRating;

    $params = $this->extractRequestParams();
    $page_id = $params['pageid'];

    /*
    MWDebug::log(
      "HWGetRatingsApi::execute: \n" .
      print_r($params, true)
    );
    */

    // Exit with an error if pageid is not valid (eg. non-existent or deleted)
    $this->getTitleOrPageId($params);

    $dbr = wfGetDB(DB_SLAVE);

    $res = $dbr->select(
      array(
        'hw_ratings',
        'user'
      ),
      array(
        'hw_user_id',
        'hw_page_id',
        'hw_rating',
        'hw_timestamp',
        'user_name'
      ),
      array(
        'hw_page_id' => $page_id
      ),
      __METHOD__,
      array(),
      array(
        'user' => array(
          'LEFT JOIN',
          array('hw_ratings.hw_user_id = user.user_id')
        )
      )
    );

    $this->getResult()->addValue( array( 'query' ), 'ratings', array() );
    //$this->getResult()->addValue( array( 'query' ), 'distribution', array() );

    // $distribution will hold how many users gave one rating point to the page, how many gave two, etc.
    $distribution = array();
    for ( $i = $wgHwRatingsMinRating; $i <= $wgHwRatingsMaxRating; $i++ ) {
      $distribution[$i] = array(
        'count' => 0 // `percentage` field will be set later on
      );
    }

    $rating_count = $res->numRows();

    /*
    MWDebug::log(
      "HWGetRatingsApi::execute: - rating_count: " . $rating_count
    );
    */

    foreach( $res as $row ) {
      $vals = array(
        'pageid' => intval($row->hw_page_id),
        'rating' => intval($row->hw_rating),
        'timestamp' => $row->hw_timestamp ? $row->hw_timestamp : '',
        'user_id' => intval($row->hw_user_id),
        'user_name' => $row->user_name ? $row->user_name : ''
      );
      $this->getResult()->addValue( array( 'query', 'ratings' ), null, $vals );

      $distribution[intval($row->hw_rating)]['count']++;
    }

    /*
    MWDebug::log(
      "HWGetRatingsApi::execute: distribution\n" .
      print_r($distribution, true)
    );
    */

    if ($rating_count != 0) { // prevent division by zero, and include distribution in result set only if there are ratings
      // Will not always sum up precisely to 100%, but such is life...
      foreach ($distribution as &$frequency) {
        $frequency['percentage'] = round(($frequency['count'] / $rating_count) * 100, 3);
      }
      unset($frequency);

      $this->getResult()->addValue( array( 'query' ), 'distribution', $distribution );
    }

    return true;
  }

  // API endpoint description
  public function getDescription() {
    return 'Get all the ratings of a page';
  }

  // Parameters
  public function getAllowedParams() {
    return array(
      'pageid' => array (
        ApiBase::PARAM_TYPE => 'integer',
        ApiBase::PARAM_REQUIRED => true
      )
    );
  }

  // Describe the parameters
  public function getParamDescription() {
    return array_merge(
      parent::getParamDescription(),
      array('pageid' => 'Id of the page')
    );
  }
}
