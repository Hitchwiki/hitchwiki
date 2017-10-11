<?php

class HWWaitingTimeHooks {
  public static function onLoadExtensionSchemaUpdates( DatabaseUpdater $updater ) {
    $updater->addExtensionTable( 'hw_waiting_time', dirname( __FILE__ ) . '/sql/db-hw_waiting_time.sql' );
    $updater->addExtensionTable( 'hw_waiting_time_avg', dirname( __FILE__ ) . '/sql/db-hw_waiting_time_avg.sql' );

    return true;
  }

  public static function onArticleDeleteComplete( &$article, User &$user, $reason, $id ) {
    $dbr = wfGetDB( DB_MASTER );

    $dbr->update(
      'hw_waiting_time',
      array(
        'hw_deleted' => '1'
      ),
      array(
        'hw_page_id' => $id
      )
    );

    $dbr->update(
      'hw_waiting_time_avg',
      array(
        'hw_deleted' => '1'
      ),
      array(
        'hw_page_id' => $id
      )
    );

    return true;
  }

  public static function onArticleRevisionUndeleted( $title, $revision, $oldPageID ) {
    $newID = strval($revision->getPage());
    $oldID = strval($oldPageID);
    $dbr = wfGetDB( DB_MASTER );

    $dbr->update(
      'hw_waiting_time',
      array(
        'hw_deleted' => '0',
        'hw_page_id' => $newID
      ),
      array(
        'hw_page_id' => $oldID
      )
    );

    $dbr->update(
      'hw_waiting_time_avg',
      array(
        'hw_deleted' => '0',
        'hw_page_id' => $newID
      ),
      array(
        'hw_page_id' => $oldID
      )
    );

    return true;
  }
}



