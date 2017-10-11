#
# Turn spots from old (pre-Feb 2015) Hitchwiki maps database tables:
#
# - hitchwiki_maps.t_points
# - hitchwiki_maps.t_points_descriptions
#
# into wiki articles in the new setup based on Semantic MediaWiki
#
# Also, creates hitchwiki_migrate.migrated_spots table containing:
#
# - point_id -- primary key of a spot (point) in the old DB;
# - page_id -- ID of the newly created MediaWiki article with spot info;
# - user_id -- MediaWiki ID of the user who created the spot;
# - datetime -- spot creation time (MySQL datetime).
#
# for future use by other migration scripts (eg. to migrate comments)
#

# Allow imports from parent dir
import os,sys,inspect
currentdir = os.path.dirname(os.path.abspath(inspect.getfile(inspect.currentframe())))
parentdir = os.path.dirname(currentdir)
sys.path.insert(0,parentdir)

import signal
import sys
import os.path

import pywikibot

import requests
import urllib
import hashlib

import json
import ConfigParser

import MySQLdb

from ftfy import fix_text

print

# Handle Ctrl+C gracefully
def signal_handler(signal, frame):
    print 'Exit: Ctrl+C pressed'
    sys.exit(0)
signal.signal(signal.SIGINT, signal_handler)

site = pywikibot.Site()

# Load wiki settings
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

# Create (old) point_id <-> (new) page_id  migration mappings table
try: # Not using CREATE TABLE IF EXISTS to avoid MySQL warning if indeed exists
    table_cur = db.cursor()
    table_cur.execute(
        'CREATE TABLE hitchwiki_migrate.migrated_spots (' +
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
    "SELECT p.id AS point_id, p.user, p.lat, p.lon, p.datetime, ppm.page_id, " +
            # @TODO: fix performance issue; index is ignored :/ using a separate query for now
            # " ( SELECT d.description" +
            #     " FROM hitchwiki_maps.t_points_descriptions AS d" +
            #     " WHERE d.fk_point = p.id" +
            #         " AND d.language = 'en_UK'" +
            #     " LIMIT 1"
            # " ) AS description" # most recent English description
            " '' AS description"
        " FROM hitchwiki_maps.t_points AS p" +
        " LEFT JOIN hitchwiki_migrate.migrated_spots AS ppm" +
            " ON ppm.point_id = p.id" +
        " WHERE p.type = 1" + # ignore type = 2 (probably trip/event points)
        " ORDER BY p.id" # consistent processing order
)
points_cur.execute(sql)

count = points_cur.rowcount
for point in points_cur.fetchall() :
    title = 'Spot %s' % (point['point_id']) # point_id is a primary key, so the title is guaranteed to be unique

    print title
    print 'http://' + settings.get('general', 'domain') + '/en/' + title.replace(' ', '_') # works for simple titles
    print

    if point['page_id']: # old point with id = point_id has already got a corresponding article with id = page_id
        print 'Skip: already migrated'
        print
    else:
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

        # Request spot's country and nearby big city from the API
        params = {
            'action': 'hwfindnearbycityapi',
            'format': 'json',
            'lat': point['lat'],
            'lng': point['lon']
        }
        r = requests.get(api_url, params=params)
        obj = json.loads(r.text)

        if len(obj['cities']) != 0:
            cities = ','.join(city['name'] for city in obj['cities']) # for "cities" plural think for eg. Ruhr area
        else:
            cities = ''
        country = obj['country']

        if not country:
            print 'Warning: country lookup failed; use blank value'
            print

        # Create MediaWiki page for the spot
        page = pywikibot.Page(site, title)
        page.text = ( # no way to preserve user id ;(
            "{{Spot\n" +
            ("|Description=%s\n" % description) +
            ("|Cities=%s\n" % cities) +
            ("|Country=%s\n" % country) +
            "|CardinalDirection=\n" +
            "|CitiesDirection=\n" +
            "|RoadsDirection=\n" +
            ("|Location=%s, %s\n" % (point['lat'], point['lon'])) +
            "}}\n"
        )
        print page.text
        print

        page.save()
        print

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

        # Insert (old) point_id and (new) page_id into spot migration logging table
        table_cur = db.cursor()
        table_cur.execute(
            'INSERT INTO hitchwiki_migrate.migrated_spots (point_id, page_id, user_id, datetime)' +
                " VALUES (%s, %s, %s, %s)" % (point['point_id'], pageid, user_id, datetime)
        )
        db.commit()

        # @TODO: using SQL set page's create time and user id to the values from migrated_spots

    print "-------------------------------------------------------------------------------"
    print

print 'Total:', count
