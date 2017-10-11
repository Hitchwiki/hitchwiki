<?php

/**
 *
 */
class HWMapApi extends ApiBase {

  public function execute() {

    // Get parameters
    $params = $this->extractRequestParams();
    $ne_lat = (double) $params['NElat'];
    $sw_lat = (double) $params['SWlat'];
    $sw_lon = (double) $params['SWlon'];
    $ne_lon = (double) $params['NElon'];

    // Send the query do the database
    $dbr = wfGetDB(DB_SLAVE);

    // Ratings API available
    if (class_exists('HWAvgRatingApi')) {
      $res = $dbr->select(
        array(
          'geo_tags',
          'categorylinks',
          'hw_ratings_avg',
          'page'),
        array(
          'gt_page_id',
          'gt_lat',
          'gt_lon',
          'cl_to',
          'hw_average_rating',
          'page_title'
        ),
        array(
          'gt_lat <' . $ne_lat,
          'gt_lat >' . $sw_lat,
          'gt_lon >' . $sw_lon,
          'gt_lon <' . $ne_lon,
        ),
        __METHOD__,
        array(),
        array(
          'categorylinks' => array(
            'JOIN',
            array('gt_page_id = cl_from AND cl_to = \'Cities\' OR gt_page_id = cl_from AND cl_to = \'Spots\'')
          ),
          'hw_ratings_avg' => array(
            'LEFT JOIN ',
            array('gt_page_id=hw_page_id')
          ),
          'page' => array(
            'LEFT JOIN ',
            array('gt_page_id=page_id')
          )
        )
      );

      // Build the api result
      foreach ($res as $row) {
        if (!$params['category'] || $row->cl_to == $params['category']) {
          $vals = array(
            'id' => $row->gt_page_id,
            'location' => array(
              floatval($row->gt_lat),
              floatval($row->gt_lon)
            ),
            'title' => $row->page_title,
            'category' => $row->cl_to,
            'average_rating' => floatval($row->hw_average_rating)
          );
          $this->getResult()->addValue(array( 'query', 'spots' ), null, $vals);
        }
      }

    // No ratings API available
    } else {
      $res = $dbr->select(
        array( 'geo_tags', 'categorylinks'),
        array( 'gt_page_id', 'gt_lat', 'gt_lon', 'cl_to'),
        array(
          'gt_lat <' . $ne_lat,
          'gt_lat >' . $sw_lat,
          'gt_lon >' . $sw_lon,
          'gt_lon <' . $ne_lon
        ),
        __METHOD__,
        array(),
        array(
          'categorylinks' => array(
            'JOIN',
            array('gt_page_id=cl_from')
          )
        )
      );

      // Build the api result
      foreach( $res as $row ) {
        $vals = array(
          'id' => $row->gt_page_id,
          'location' => array(
            floatval($row->gt_lat),
            floatval($row->gt_lon)
          ),
          'category' => $row->cl_to
        );

        $this->getResult()->addValue(array('query', 'spots'), null, $vals);
      }

    }

    return true;
  }

  // API endpoint description
  public function getDescription() {
    return 'Get pages located in a specified bounding box.';
  }

  // Parameters
  public function getAllowedParams() {
    return array(
      'NElat' => array(
        ApiBase::PARAM_TYPE => 'string',
        ApiBase::PARAM_REQUIRED => true
      ),
      'NElon' => array(
        ApiBase::PARAM_TYPE => 'string',
        ApiBase::PARAM_REQUIRED => true
      ),
      'SWlat' => array(
        ApiBase::PARAM_TYPE => 'string',
        ApiBase::PARAM_REQUIRED => true
      ),
      'SWlon' => array(
        ApiBase::PARAM_TYPE => 'string',
        ApiBase::PARAM_REQUIRED => true
      ),
      'category' => array(
        ApiBase::PARAM_TYPE => 'string'
      ),
    );
  }

  // Describe the parameter
  public function getParamDescription() {
    return array_merge(
      parent::getParamDescription(),
      array(
        'NElat' => 'North East latitude of the bounding box',
        'NElon' => 'North East longitude of the bounding box',
        'SWlat' => 'South West latitude of the bounding box',
        'SWlon' => 'South West longitude of the bounding box',
        'category' => 'Restricted category',
      )
    );
  }

}
