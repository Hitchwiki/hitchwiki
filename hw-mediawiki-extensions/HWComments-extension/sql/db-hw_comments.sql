-- SQL schema for HWComments

CREATE TABLE hw_comments (
  hw_comment_id int NOT NULL AUTO_INCREMENT PRIMARY KEY,
  hw_user_id int unsigned NOT NULL,
  hw_page_id int unsigned NOT NULL,
  hw_timestamp char(14) NOT NULL,
  hw_commenttext text NOT NULL,
  hw_deleted BOOL NOT NULL DEFAULT false
);

CREATE INDEX hw_user_primary
  ON hw_comments ( hw_user_id );

CREATE INDEX hw_page_secondary
  ON hw_comments ( hw_page_id );
