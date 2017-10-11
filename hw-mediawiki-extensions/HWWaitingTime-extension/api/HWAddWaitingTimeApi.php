<?php

class HWAddWaitingTimeApi extends HWWaitingTimeBaseApi {
  public function execute() {
    // https://www.mediawiki.org/wiki/Manual:$wgUser
    global $wgUser;

    if (!$wgUser->isAllowed('edit')) {
      $this->dieUsage('You do not have permission to add waiting time', 'permissiondenied');
    }

    $params = $this->extractRequestParams();
    $page_id = $params['pageid'];
    $waiting_time = $params['waiting_time'];
    $timestamp = wfTimestampNow();

    // Exit with an error if pageid is not valid (eg. non-existent or deleted)
    $this->getTitleOrPageId($params);

    $dbw = wfGetDB(DB_MASTER);
    $dbw->insert(
      'hw_waiting_time',
      array(
        'hw_user_id' => $wgUser->getId(),
        'hw_page_id' => $page_id,
        'hw_waiting_time' => $waiting_time,
        'hw_timestamp' => $timestamp
      )
    );
    $waiting_time_id = $dbw->insertId();

    $aggregate = $this->updateWaitingTimeAverages($page_id);

    $this->getResult()->addValue('query', 'average', intval(round($aggregate['average']), 10));
    $this->getResult()->addValue('query', 'min', intval(round($aggregate['min']), 10));
    $this->getResult()->addValue('query', 'max', intval(round($aggregate['max']), 10));
    $this->getResult()->addValue('query', 'count', intval($aggregate['count'], 10));
    $this->getResult()->addValue('query', 'pageid', intval($page_id));
    $this->getResult()->addValue('query', 'waiting_time_id', $waiting_time_id);
    $this->getResult()->addValue('query', 'timestamp', $timestamp);

    return true;
  }

  // Description
  public function getDescription() {
    return 'Add waiting time for page';
  }

  // Parameters
  public function getAllowedParams() {
    global $wgHwWaitingTimeRangeBounds;

    $minWaitingTime = $wgHwWaitingTimeRangeBounds[0];
    $maxWaitingTime = $wgHwWaitingTimeRangeBounds[count($wgHwWaitingTimeRangeBounds) - 1]; // don't use end() to avoid possible interference with outer loops
    return array(
      'waiting_time' => array(
        ApiBase::PARAM_TYPE => 'integer',
        ApiBase::PARAM_REQUIRED => true,
        ApiBase::PARAM_MIN => $minWaitingTime,
        ApiBase::PARAM_MAX => $maxWaitingTime,
        ApiBase::PARAM_RANGE_ENFORCE => true
      ),
      'pageid' => array(
        ApiBase::PARAM_TYPE => 'integer',
        ApiBase::PARAM_REQUIRED => true
      ),
      'token' => array(
        ApiBase::PARAM_TYPE => 'string',
        ApiBase::PARAM_REQUIRED => true
      )
    );
  }

  // Describe the parameters
  public function getParamDescription() {
    return array_merge( parent::getParamDescription(), array(
      'waiting_time' => 'Waiting time (in minutes)',
      'pageid' => 'Page id',
      'token' => 'csrf token'
    ) );
  }

  public function needsToken() {
    return 'csrf';
  }
}
