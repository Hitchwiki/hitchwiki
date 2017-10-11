<?php

class HWAddRatingApi extends HWRatingsBaseApi {
  public function execute() {

    global $wgUser;

    if (!$wgUser->isAllowed('edit')) {
      $this->dieUsage('You don\'t have permission to add rating', 'permissiondenied');
    }

    // Get request params
    $params = $this->extractRequestParams();

    /*
    MWDebug::log(
      "HWAddRatingApi::execute: \n" .
      print_r($params, true)
    );
    */

    // Die if no `$page_id`
    if (!isset($params['pageid']) || empty($params['pageid'])) {
      $this->dieUsage('HWAddRatingApi: no page ID defined. #fhj3h3');
    }

    // Die if no `$rating`
    if (!isset($params['rating']) || $params['rating'] === '') {
      $this->dieUsage('HWAddRatingApi: no rating defined. #4j3888');
    }

    $page_id = $params['pageid'];
    $user_id = $wgUser->getId();
    $rating = $params['rating'];
    $timestamp = wfTimestampNow();

    // Exit with an error if `pageid` is not valid (eg. non-existent or deleted)
    $this->getTitleOrPageId($params);

    $dbw = wfGetDB(DB_MASTER);

    // Avoid duplicate entry for the same user by deleting any previosu entries
    $dbw->delete(
      'hw_ratings',
      array(
        'hw_user_id' => $user_id,
        'hw_page_id' => $page_id
      )
    );

    // Insert new rating to the DB
    $dbw->insert(
      'hw_ratings',
      array(
        'hw_user_id' => $user_id,
        'hw_page_id' => $page_id,
        'hw_rating' => $rating,
        'hw_timestamp' => $timestamp
      )
    );

    $aggregate = $this->updateRatingAverages($page_id);

    $this->getResult()->addValue('query', 'average', round($aggregate['average'], 2));
    $this->getResult()->addValue('query', 'count', intval($aggregate['count']));
    $this->getResult()->addValue('query', 'pageid', intval($page_id));
    $this->getResult()->addValue('query', 'timestamp', $timestamp);

    return true;
  }

  // API parameters
  public function getAllowedParams() {
    global $wgHwRatingsMinRating,
           $wgHwRatingsMaxRating;

    return array(
      'pageid' => array (
        ApiBase::PARAM_TYPE => 'integer',
        ApiBase::PARAM_REQUIRED => true
      ),
      'rating' => array (
        ApiBase::PARAM_TYPE => 'integer',
        ApiBase::PARAM_REQUIRED => true,
        ApiBase::PARAM_MIN => $wgHwRatingsMinRating,
        ApiBase::PARAM_MAX => $wgHwRatingsMaxRating,
        ApiBase::PARAM_RANGE_ENFORCE => true
      ),
      'token' => array (
        ApiBase::PARAM_TYPE => 'string',
        ApiBase::PARAM_REQUIRED => true
      )
    );
  }

  // Describe the API parameters
  public function getParamDescription() {
    global $wgHwRatingsMinRating,
           $wgHwRatingsMaxRating;

    return array_merge( parent::getParamDescription(), array(
      'rating' => 'Rating [' . $wgHwRatingsMinRating . '..' . $wgHwRatingsMaxRating . ']',
      'pageid' => 'Page id',
      'token' => 'csrf token'
    ) );
  }

  // API endpoint description
  public function getDescription() {
    return 'Add or update user\'s rating for an article.';
  }

  public function needsToken() {
    return 'csrf';
  }
}
