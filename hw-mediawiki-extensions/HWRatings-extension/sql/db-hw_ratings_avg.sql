-- SQL schema for HWRatings counts and averages

CREATE TABLE hw_ratings_avg (
  hw_page_id int unsigned PRIMARY KEY NOT NULL,
  hw_count_rating int unsigned NOT NULL,
  hw_average_rating decimal(5,4) unsigned NOT NULL,
  hw_deleted bool NOT NULL DEFAULT false
);
