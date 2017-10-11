<?php

class HWGetWaitingTimesApi extends HWWaitingTimeBaseApi {
  public function execute() {
    $params = $this->extractRequestParams();
    $page_id = $params['pageid'];

    // Exit with an error if pageid is not valid (eg. non-existent or deleted)
    $this->getTitleOrPageId($params);

    $dbr = wfGetDB( DB_SLAVE );
    $res = $dbr->select(
      array(
        'hw_waiting_time',
        'user'
      ),
      array(
        'hw_user_id',
        'hw_page_id',
        'hw_waiting_time_id',
        'hw_waiting_time',
        'hw_timestamp',
        'user_name'
      ),
      array(
        'hw_page_id' => $page_id
      ),
      __METHOD__,
      array(),
      array( 'user' => array( 'LEFT JOIN', array(
        'hw_waiting_time.hw_user_id = user.user_id',
      ) ) )
    );

    $this->getResult()->addValue( array( 'query' ), 'waiting_times', array() );
    //$this->getResult()->addValue( array( 'query' ), 'distribution', array() );

    $ranges = $this->waitingTimeRanges();

    // $distribution will hold waiting time frequencies for each predefined range
    $distribution = array();
    foreach ( $ranges as $key => $range ) {
      $distribution[$key] = array(
        // if you need these two, blame @simison for objecting to have them included in the response!
        //'range_min' => $range['min'],
        //'range_max' => $range['max'],

        'count' => 0 // 'percentage' field will be set later on
      );
    }

    $waiting_time_count = $res->numRows();
    foreach ($res as $row) {
      $waiting_time = intval($row->hw_waiting_time, 10);
      $vals = array(
        'pageid' => intval($row->hw_page_id, 10),
        'waiting_time_id' => $row->hw_waiting_time_id,
        'waiting_time' => $waiting_time,
        'timestamp' => $row->hw_timestamp,
        'user_id' => $row->hw_user_id,
        'user_name' => $row->user_name ? $row->user_name : ''
      );
      $this->getResult()->addValue( array( 'query', 'waiting_times' ), null, $vals );

      foreach ($ranges as $key => $range) {
        if ($waiting_time <= $range['max']) {
          $distribution[$key]['count']++;
          break;
        }
      }
    }

    if ($waiting_time_count !== 0) { // prevent division by zero, and include distribution in result set only if there are waiting times
      // Will not always sum up precisely to 100%, but such is life...
      foreach ($distribution as &$frequency) {
        $frequency['percentage'] = round(($frequency['count'] / $waiting_time_count) * 100, 3);
      }
      unset($frequency);

      $this->getResult()->addValue( array( 'query' ), 'distribution', $distribution );
    }

    return true;
  }

  // Description
  public function getDescription() {
    return 'Get all the waiting times of a page';
  }

  // Parameters
  public function getAllowedParams() {
    return array(
      'pageid' => array(
        ApiBase::PARAM_TYPE => 'integer',
        ApiBase::PARAM_REQUIRED => true
      )
    );
  }

  // Describe the parameters
  public function getParamDescription() {
    return array_merge( parent::getParamDescription(), array(
      'pageid' => 'Page id',
    ) );
  }
}
