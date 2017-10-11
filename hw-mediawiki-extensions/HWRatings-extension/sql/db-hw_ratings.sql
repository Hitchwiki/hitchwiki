-- SQL schema for HWRatings

CREATE TABLE hw_ratings (
  hw_rating_id int NOT NULL AUTO_INCREMENT PRIMARY KEY,
  hw_user_id int unsigned NOT NULL,
  hw_page_id int unsigned NOT NULL,
  hw_rating tinyint unsigned NOT NULL,
  hw_timestamp char(14) DEFAULT NULL,
  hw_deleted bool NOT NULL DEFAULT false
);

CREATE INDEX hw_page_primary
  ON hw_ratings (hw_page_id);

CREATE INDEX hw_user_page_secondary
  ON hw_ratings (hw_user_id, hw_page_id);
