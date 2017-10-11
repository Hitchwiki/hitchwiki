<?php

/**
 * Base functionality shared by API calls
 */
abstract class HWCommentsBaseApi extends ApiBase {
  public function updateCommentCounts($page_id) {
    $page_id = intval($page_id);
    $dbw = wfGetDB( DB_MASTER );

    // Get fresh comment count
    $res = $dbw->select(
      'hw_comments',
      array(
        'COUNT(*) AS count_comment'
      ),
      array(
        'hw_page_id' => $page_id
      )
    );
    $row = $res->fetchRow();
    $count = intval($row['count_comment'], 10);

    if ($count != 0) {
	    // Update comment count cache
	    $dbw->upsert(
	      'hw_comments_count',
	      array(
	        'hw_page_id' => $page_id,
	        'hw_comments_count' => $count
	      ),
	      array('hw_page_id'),
	      array(
	        'hw_comments_count' => $count
	      )
	    );
    } else { // $count == 0
      // Delete comment count for the page, if the page doesn't have any comments
      $dbw->delete(
        'hw_comments_count',
        array(
          'hw_page_id' => $page_id
        )
      );
    }

    return array(
      'count' => $count
    );
  }
}
