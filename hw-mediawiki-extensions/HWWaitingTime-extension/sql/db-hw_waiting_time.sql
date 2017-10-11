-- SQL schema for HWWaitingTime

CREATE TABLE hw_waiting_time (
  hw_waiting_time_id int unsigned NOT NULL AUTO_INCREMENT PRIMARY KEY,
  hw_user_id int unsigned NOT NULL,
  hw_page_id int unsigned NOT NULL,
  hw_waiting_time int(3) unsigned NOT NULL,
  hw_timestamp char(14) NOT NULL,
  hw_deleted bool NOT NULL DEFAULT false
);

CREATE INDEX hw_page_user_primary
  ON hw_waiting_time (hw_user_id, hw_page_id);

CREATE INDEX hw_page_secondary
  ON hw_waiting_time ( hw_page_id );

CREATE INDEX hw_waiting_time_tertiary
  ON hw_waiting_time ( hw_waiting_time );
