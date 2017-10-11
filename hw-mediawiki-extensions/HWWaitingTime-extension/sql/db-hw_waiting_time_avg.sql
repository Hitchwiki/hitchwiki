-- SQL schema for HWWaitingTime counts and averages

CREATE TABLE hw_waiting_time_avg (
  hw_page_id int unsigned PRIMARY KEY NOT NULL,
  hw_average_waiting_time decimal(10,4) unsigned NOT NULL,
  hw_min_waiting_time int unsigned NOT NULL,
  hw_max_waiting_time int unsigned NOT NULL,
  hw_count_waiting_time int unsigned NOT NULL,
  hw_deleted bool NOT NULL DEFAULT false
);
