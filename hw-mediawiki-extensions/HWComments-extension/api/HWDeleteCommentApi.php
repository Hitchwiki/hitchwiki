<?php
class HWDeleteCommentApi extends HWCommentsBaseApi {
  public function execute() {
    global $wgUser;
    if (!$wgUser->isAllowed('edit')) {
      $this->dieUsage("You don't have permission to delete comment", "permissiondenied");
    }

    $params = $this->extractRequestParams();
    $comment_id = $params['comment_id'];

    $dbw = wfGetDB( DB_MASTER );
    $res = $dbw->select(
      'hw_comments',
      array(
        'hw_user_id',
        'hw_page_id'
      ),
      array(
        'hw_comment_id' => $comment_id
      )
    );

    $row = $res->fetchObject();
    if (!$row) {
      $this->dieUsage("There is no comment with specified id", "nosuchcommentid");
    }

    if ($row->hw_user_id != $wgUser->getId()) {
      $this->dieUsage("You don't have permission to delete comment that was authored by another user", "permissiondenied");
    }

    $dbw->delete(
      'hw_comments',
      array(
        'hw_comment_id' => $comment_id
      )
    );

    $page_id = $row->hw_page_id;

    $aggregate = $this->updateCommentCounts($page_id);

    $this->getResult()->addValue('query' , 'count', intval($aggregate['count']));
    $this->getResult()->addValue('query' , 'pageid', intval($page_id));

    return true;
  }

  // Description
  public function getDescription() {
    return 'Delete comment from a spot';
  }

  // Parameters
  public function getAllowedParams() {
    return array(
      'comment_id' => array (
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
          'comment_id' => 'Comment id',
          'token' => 'User edit token'
      ) );
  }

  public function needsToken() {
      return 'csrf';
  }

}
