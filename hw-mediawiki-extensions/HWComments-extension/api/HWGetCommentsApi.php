<?php

class HWGetCommentsApi extends HWCommentsBaseApi {
  public function execute() {
    $params = $this->extractRequestParams();
    $page_id = $params['pageid'];
    $dontparse = $params['dontparse'];

    // Exit with an error if pageid is not valid (eg. non-existent or deleted)
    $this->getTitleOrPageId($params);

    $dbr = wfGetDB( DB_SLAVE );
    $res = $dbr->select(
      array(
        'hw_comments',
        'user'
      ),
      array(
        'hw_user_id',
        'hw_page_id',
        'hw_comment_id',
        'hw_commenttext',
        'hw_timestamp',
        'user_name'
      ),
      array(
        'hw_page_id' => $page_id
      ),
      __METHOD__,
      array(),
      array( 'user' => array( 'LEFT JOIN', array(
        'hw_comments.hw_user_id = user.user_id',
      ) ) )
    );

    $this->getResult()->addValue( array( 'query' ), 'comments', array() );
    foreach( $res as $row ) {
      if($dontparse != true) {
        $parse_request = new DerivativeRequest(
          $this->getRequest(),
          array(
            'action' => 'parse',
            'text' => $row->hw_commenttext,
            'prop' => 'text',
            'disablepp' => ''
          ),
          true
        );
        $parse_api = new ApiMain( $parse_request );
        $parse_api->execute();
        $parsed_data = $parse_api->getResult()->getResultData( null, ['BC' => [], 'Types' => [], 'Strip' => 'all'] );
        $commenttext = $parsed_data['parse']['text']['*'];
      } else {
        $commenttext = $row->hw_commenttext;
      }

      $vals = array(
        'pageid' => intval($row->hw_page_id),
        'comment_id' => intval($row->hw_comment_id),
        'commenttext' => $commenttext,
        'timestamp' => $row->hw_timestamp,
        'user_id' => intval($row->hw_user_id),
        'user_name' => $row->user_name ? $row->user_name : '',
      );
      $this->getResult()->addValue( array( 'query', 'comments' ), null, $vals );
    }

    return true;
  }

  // Description
  public function getDescription() {
    return 'Get all the comments of a page';
  }

  // Parameters
  public function getAllowedParams() {
    return array(
      'pageid' => array (
        ApiBase::PARAM_TYPE => 'integer',
        ApiBase::PARAM_REQUIRED => true
      ),
      'dontparse' => array (
        ApiBase::PARAM_TYPE => 'boolean'
      )
    );
  }

  // Describe the parameters
  public function getParamDescription() {
    return array_merge( parent::getParamDescription(), array(
      'pageid' => 'Page id',
      'dontparse' => 'Set to true to get not parsed wikitext'
    ) );
  }
}
