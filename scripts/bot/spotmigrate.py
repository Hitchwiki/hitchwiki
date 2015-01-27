#
# Migrate spots from old (pre-Feb 2015) Hitchwiki maps DB to the new setup based on
# Semantic MediaWiki and custom MediaWiki extensions
#

import pywikibot
import json, requests, urllib
import hashlib
import os.path
import ConfigParser
import MySQLdb

site = pywikibot.Site()

settings = ConfigParser.ConfigParser()
settings.read('../../configs/settings.ini')
dummy_user_id = 0

db = MySQLdb.connect(
    host=settings.get('db', 'host'),
    user=settings.get('db', 'username'),
    passwd=settings.get('db', 'password'),
    db=settings.get('db', 'database')
)
points_cur = db.cursor(MySQLdb.cursors.DictCursor)

# Fetch points and their English description from the old DB
sql = (
    "SELECT p.id AS point_id, p.user, p.lat, p.lon, p.datetime," +
            # @TODO: fix performance issue; index is ignored :/
            # " ( SELECT d.description" +
            #     " FROM hitchwiki_maps.t_points_descriptions AS d" +
            #     " WHERE d.fk_point = p.id" +
            #         " AND d.language = 'en_UK'" +
            #     " LIMIT 1"
            # " ) AS description" # most recent English description
            " '' AS description"
        " FROM hitchwiki_maps.t_points AS p" +
        " WHERE p.type = 1" # ignore type = 2 (probably trip/event points)
)
points_cur.execute(sql)

# Create a temporary (old) point_id <-> (new) page_id mappings table
table_cur = db.cursor()
table_cur.execute(
    'DROP TABLE IF EXISTS hitchwiki_maps.point_page_mappings'
)
table_cur.execute(
    'CREATE TABLE hitchwiki_maps.point_page_mappings (' +
        ' point_id integer NOT NULL PRIMARY KEY,' +
        ' page_id integer NOT NULL UNIQUE,' +
        ' user_id integer DEFAULT NULL,' +
        ' datetime datetime DEFAULT NULL'
    ')'
)

count = points_cur.rowcount
for point in points_cur.fetchall() :
    #print point['point_id'], point['user'], point['lat'], point['lon'], point['description']

    # Create MediaWiki page for the spot
    title = 'Spot %s (%s %s)' % (point['point_id'], point['lat'], point['lon'])
    print title
    page = pywikibot.Page(site, title)
    page.text = ( # no way to preserve user id ;(
        "{{Spot\n" +
        ("|Description=%s\n" % point["description"]) +
        "|Cities=\n" +
        "|Country=\n" +
        "|CardinalDirection=\n" +
        "|CitiesDirection=\n" +
        "|RoadsDirection=\n" +
        ("|Location=%s, %s\n" % (point['lat'], point['lon'])) +
        "}}"
    )
    print page.text
    page.save()

    # Get page id (_pageid isn't to be relied upon, but thank Thor it works)
    page.get()
    pageid = page._pageid

    if point["user"]:
        user_id = point["user"]
    else:
        user_id = dummy_user_id

    if point["datetime"]:
        datetime = "'" + str(point["datetime"]) + "'"
    else:
        datetime = "NULL"

    # Insert into (old) point_id and (new) page_id into the temporary mappings table
    table_cur = db.cursor()
    table_cur.execute(
        'INSERT INTO hitchwiki_maps.point_page_mappings (point_id, page_id, user_id, datetime)' +
            " VALUES (%s, %s, %s, %s)" % (point['point_id'], pageid, user_id, datetime)
    )
    db.commit()
    # @TODO: using SQL set page's create time and user id to the values from point_page_mappings

    print

print 'total: ', count

print 'Import spot comments...'

comments_cur = db.cursor()
comments_cur.execute(
    'INSERT INTO hitchwiki_en.hw_comments' +
        ' (hw_comment_id, hw_user_id, hw_page_id, hw_timestamp, hw_commenttext)' +
    " SELECT c.id, c.fk_user, ppm.page_id, DATE_FORMAT(c.datetime, '%Y%m%d%H%i%S'), c.comment" +
        ' FROM hitchwiki_maps.t_comments AS c' +
        ' LEFT JOIN hitchwiki_maps.point_page_mappings AS ppm' +
            ' ON ppm.point_id = c.fk_place'
)
db.commit()

print 'Import spot waiting times...'

waiting_times_cur = db.cursor()
waiting_times_cur.execute(
    'INSERT INTO hitchwiki_en.hw_waiting_time' +
        ' (hw_waiting_time_id, hw_user_id, hw_page_id, hw_timestamp, hw_waiting_time)' +
    " SELECT w.id, w.fk_user, ppm.page_id, DATE_FORMAT(w.datetime, '%Y%m%d%H%i%S'), w.waitingtime" +
        ' FROM hitchwiki_maps.t_waitingtimes AS w' +
        ' LEFT JOIN hitchwiki_maps.point_page_mappings AS ppm' +
            ' ON ppm.point_id = w.fk_point'
)
db.commit()

print 'Import spot ratings...'

comments_cur = db.cursor()
comments_cur.execute(
    'INSERT INTO hitchwiki_en.hw_ratings' +
        ' (hw_rating_id, hw_user_id, hw_page_id, hw_timestamp, hw_rating)' +
    " SELECT r.id, r.fk_user, ppm.page_id, DATE_FORMAT(r.datetime, '%Y%m%d%H%i%S'), 6 - r.rating" +
        ' FROM hitchwiki_maps.t_ratings AS r' +
        ' LEFT JOIN hitchwiki_maps.point_page_mappings AS ppm' +
            ' ON ppm.point_id = r.fk_point' +
        ' WHERE r.rating <> 0'
)
db.commit()

# @TODO: update aggregate data tables