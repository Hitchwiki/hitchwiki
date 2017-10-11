<?php

class HWDeleteWaitingTimeApi extends HWWaitingTimeBaseApi {

  public function execute() {
    // https://www.mediawiki.org/wiki/Manual:$wgUser
    global $wgUser;

    if (!$wgUser->isAllowed('edit')) {
      $this->dieUsage('You do not have permission to delete waiting time.', 'permissiondenied');
    }

    $params = $this->extractRequestParams();
    $waiting_time_id = $params['waiting_time_id'];

    $dbw = wfGetDB( DB_MASTER );
    $res = $dbw->select(
      'hw_waiting_time',
      array(
        'hw_user_id',
        'hw_page_id'
      ),
      array(
        'hw_waiting_time_id' => $waiting_time_id
      )
    );

    $row = $res->fetchObject();
    if (!$row) {
      $this->dieUsage('There is no waiting time with specified id. #93hb2h', 'nosuchwaitingtimeid');
    }

    // `$wgUser->getId()` returns `0` for non-authenticated users
    if ($row->hw_user_id !== $wgUser->getId()) {
      $this->dieUsage('You do not have permission to delete waiting time that was authored by another user.', 'permissiondenied');
    }

    $dbw->delete(
      'hw_waiting_time',
      array(
        'hw_waiting_time_id' => $waiting_time_id
      )
    );

    $page_id = $row->hw_page_id;

    $aggregate = $this->updateWaitingTimeAverages($page_id);

    $this->getResult()->addValue('query', 'average', intval(round($aggregate['average']), 10));
    $this->getResult()->addValue('query', 'min', intval(round($aggregate['min']), 10));
    $this->getResult()->addValue('query', 'max', intval(round($aggregate['max']), 10));
    $this->getResult()->addValue('query', 'count', intval($aggregate['count'], 10));
    $this->getResult()->addValue('query', 'pageid', intval($page_id, 10));

    return true;
  }

  // Description
  public function getDescription() {
    return 'Delete waiting time of page';
  }

  // Parameters
  public function getAllowedParams() {
    return array(
      'waiting_time_id' => array(
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
      'waiting_time_id' => 'Waiting time id',
      'token' => 'csrf token'
    ) );
  }

  public function needsToken() {
    return 'csrf';
  }

}
