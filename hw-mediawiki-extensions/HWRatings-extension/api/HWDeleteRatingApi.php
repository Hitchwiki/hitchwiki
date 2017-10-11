<?php

class HWDeleteRatingApi extends HWRatingsBaseApi {
  public function execute() {
    global $wgUser;
    if (!$wgUser->isAllowed('edit')) {
      $this->dieUsage('You do not have permission to remove ratings', 'permissiondenied');
    }

    $params = $this->extractRequestParams();
    $page_id = $params['pageid'];
    $user_id = $wgUser->getId();

    // Exit with an error if pageid is not valid (eg. non-existent or deleted)
    $this->getTitleOrPageId($params);

    $dbw = wfGetDB(DB_MASTER);
    $dbw->delete(
      'hw_ratings',
      array(
        'hw_user_id' => $user_id,
        'hw_page_id' => $page_id
      )
    );

    $aggregate = $this->updateRatingAverages($page_id);

    $this->getResult()->addValue('query' , 'average', round($aggregate['average'], 2));
    $this->getResult()->addValue('query' , 'count', intval($aggregate['count']));
    $this->getResult()->addValue('query' , 'pageid', intval($page_id));

    return true;
  }

  // API endpoint description
  public function getDescription() {
    return "Delete user's rating of a page";
  }

  // Parameters
  public function getAllowedParams() {
    return array(
      'pageid' => array (
        ApiBase::PARAM_TYPE => 'integer',
        ApiBase::PARAM_REQUIRED => true
      ),
      'token' => array (
        ApiBase::PARAM_TYPE => 'string',
        ApiBase::PARAM_REQUIRED => true
      )
    );
  }

  // Describe the parameters
  public function getParamDescription() {
    return array_merge( parent::getParamDescription(), array(
      'pageid' => 'Page id',
      'token' => 'csrf token'
    ) );
  }

  public function needsToken() {
    return 'csrf';
  }

}
