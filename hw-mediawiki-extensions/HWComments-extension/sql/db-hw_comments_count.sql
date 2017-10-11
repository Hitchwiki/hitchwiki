-- SQL schema for HWComments count cache

CREATE TABLE hw_comments_count (
  hw_page_id int unsigned NOT NULL PRIMARY KEY,
  hw_comments_count int unsigned NOT NULL,
  hw_deleted bool NOT NULL DEFAULT false
);
