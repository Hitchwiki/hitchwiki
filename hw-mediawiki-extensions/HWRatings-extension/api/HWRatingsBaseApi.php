<?php

/**
 * Base functionality shared by API calls
 */
abstract class HWRatingsBaseApi extends ApiBase {
  public function updateRatingAverages($page_id) {

    $page_id = intval($page_id);

    // MWDebug::log('HWRatingsBaseApi::updateRatingAverages: ' . $page_id);

    $dbw = wfGetDB(DB_MASTER);

    // Get fresh rating count and average rating
    $res = $dbw->select(
      'hw_ratings',
      array(
        // `-1`: we decided to stay away from NULLs because of JSON limitations
        'COALESCE(AVG(hw_rating), -1) AS average_rating',
        'COUNT(*) AS count_rating'
      ),
      array(
        'hw_page_id' => $page_id
      )
    );

    $row = $res->fetchRow();
    $count = intval($row['count_rating']);
    $average = doubleval($row['average_rating']);

    if ($count > 0) {
      // Update rating count and average rating cache
      $dbw->upsert(
        'hw_ratings_avg',
        array(
          'hw_page_id' => $page_id,
          'hw_count_rating' => $count,
          'hw_average_rating' => $average
        ),
        array('hw_page_id'),
        array(
          'hw_count_rating' => $count,
          'hw_average_rating' => $average
        )
      );
    // else $count == 0
    } else {
      // we decided to stay away from NULLs because of JSON limitations, thus `-1`
      $average = -1;

      // Delete rating count and average rating for the page,
      // if the page doesn't have any ratings
      $dbw->delete(
        'hw_ratings_avg',
        array(
          'hw_page_id' => $page_id,
        )
      );
    }

    return array(
      'average' => $average,
      'count' => $count
    );
  }
}
