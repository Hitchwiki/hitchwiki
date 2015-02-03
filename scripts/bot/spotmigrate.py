#
# Turn spots from old (pre-Feb 2015) Hitchwiki maps database tables:
#
# - hitchwiki_maps.t_points
# - hitchwiki_maps.t_points_descriptions
#
# into wiki articles in the new setup based on Semantic MediaWiki
#
# Also, creates a table hitchwiki_maps.point_page_mappings containing:
#
# - point_id -- primary key of a spot (point) in the old DB;
# - page_id -- ID of the newly created MediaWiki article with spot info;
# - user_id -- MediaWiki ID of the user who created the spot;
# - datetime -- spot creation time (MySQL datetime).
#
# for future use by other migration scripts (eg. to migrate comments)
#

import pywikibot
import json, requests, urllib
import hashlib
import os.path
import ConfigParser
import MySQLdb
from ftfy import fix_text

site = pywikibot.Site()

settings = ConfigParser.ConfigParser()
settings.read('../../configs/settings.ini')
api_url = 'http://' + settings.get('general', 'domain') + '/en/api.php'
dummy_user_id = 0

db = MySQLdb.connect(
    host=settings.get('db', 'host'),
    user=settings.get('db', 'username'),
    passwd=settings.get('db', 'password'),
    db=settings.get('db', 'database'),
    charset='utf8'
)

# Create a temporary (old) point_id <-> (new) page_id mappings table
table_cur = db.cursor()
#table_cur.execute(
#    'DROP TABLE IF EXISTS hitchwiki_maps.point_page_mappings'
#)
try:
    table_cur.execute(
        'CREATE TABLE hitchwiki_maps.point_page_mappings (' +
            ' point_id integer NOT NULL PRIMARY KEY,' +
            ' page_id integer NOT NULL UNIQUE,' +
            ' user_id integer DEFAULT NULL,' +
            ' datetime datetime DEFAULT NULL'
        ')'
    )
except MySQLdb.Error, e:
    if e.args[0] != 1050:
        raise
    # otherwise, error code 1050: table already exists; we just move on

# Fetch points and their English description from the old DB
points_cur = db.cursor(MySQLdb.cursors.DictCursor)
sql = (
    "SELECT p.id AS point_id, p.user, p.lat, p.lon, p.datetime," +
            # @TODO: fix performance issue; index is ignored :/ using a separate query for now
            # " ( SELECT d.description" +
            #     " FROM hitchwiki_maps.t_points_descriptions AS d" +
            #     " WHERE d.fk_point = p.id" +
            #         " AND d.language = 'en_UK'" +
            #     " LIMIT 1"
            # " ) AS description" # most recent English description
            " '' AS description"
        " FROM hitchwiki_maps.t_points AS p" +
        " LEFT JOIN hitchwiki_maps.point_page_mappings AS ppm" +
            " ON ppm.point_id = p.id" +
        " WHERE p.type = 1" + # ignore type = 2 (probably trip/event points)
            " AND ppm.point_id IS NULL" # ignore spots that have already been migrated
)
points_cur.execute(sql)

count = points_cur.rowcount
for point in points_cur.fetchall() :
    #print point['point_id'], point['user'], point['lat'], point['lon'], point['description']
    #description = point["description"]

    # Fetch latest English description for the spot
    descr_cur = db.cursor(MySQLdb.cursors.DictCursor)
    descr_cur.execute((
        'SELECT description' +
            ' FROM hitchwiki_maps.t_points_descriptions' +
            ' WHERE fk_point = %s' +
                " AND language = 'en_UK'" +
            ' ORDER BY datetime DESC' +
            ' LIMIT 1'
    ) % (point['point_id']))
    if descr_cur.rowcount != 0:
        description = descr_cur.fetchone()['description']
    else:
        description = u''
    description = fix_text(description) # we're getting crappily encoded utf-8 values from the db

    # Request nearby city from the API
    params = {
        'action': 'hwfindnearbycityapi',
        'format': 'json',
        'lat': point['lat'],
        'lng': point['lon']
    }
    r = requests.get(api_url, params=params)
    obj = json.loads(r.text)
    print obj
    if len(obj['cities']) != 0:
        cities = ','.join(city['name'] for city in obj['cities'])
    else:
        cities = ''
    print cities

    # Create MediaWiki page for the spot
    title = 'Spot %s (%s %s)' % (point['point_id'], point['lat'], point['lon'])
    print title
    page = pywikibot.Page(site, title)
    page.text = ( # no way to preserve user id ;(
        "{{Spot\n" +
        ("|Description=%s\n" % description) +
        ("|Cities=%s\n" % cities) +
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
