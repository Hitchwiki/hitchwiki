#
# Add Semantic MediaWiki templates to articles that (supposedly) correspond to
# geographic locations
#
# There are 4 location templates: Area, City, Country and Spot. All of them
# can be found in /scripts/pages/. This script handles the first three.
#
# Also, it creates hitchwiki_migrate.migrated_articles table and fills it with
# ids of pages as they are being migrated
#

# Allow imports from parent dir
import os,sys,inspect
currentdir = os.path.dirname(os.path.abspath(inspect.getfile(inspect.currentframe())))
parentdir = os.path.dirname(currentdir)
sys.path.insert(0,parentdir)

import sys
import signal

import pywikibot
from pywikibot import pagegenerators

import re
import json
import ConfigParser
from difflib import unified_diff

import MySQLdb

from lib.geonames import GeoNames
from lib.googlegeocode import GoogleGeocode

print

# Handle Ctrl+C gracefully
def signal_handler(signal, frame):
    print 'Exit: Ctrl+C pressed'
    sys.exit(0)
signal.signal(signal.SIGINT, signal_handler)

# Determine article type if the title matches
article_title_road_regex = '[A-Z]?-?\d+\s*(\((\w|\s)+\))'
article_title_border_regex = '.*border (crossing|checkpoint)'

# Article content
map_link_regex = '<map[^>]+>'
infobox_code_regex = '(?i){{infobox.*?}}'

# Load wiki settings
settings = ConfigParser.ConfigParser()
settings.read('../../configs/settings.ini')

# Load bot settings
with open('config.json') as config_file:
    config = json.load(config_file)

# Geonames geocoder wrapper
geonames = GeoNames(settings.get('vendor', 'geonames_username'), './.cache')

# Google GeoCode limits number of lookups per day
google_geocode = GoogleGeocode('./.cache')

# Article iterators
site = pywikibot.Site()
gen = pagegenerators.AllpagesPageGenerator(site=site)
disamb_cat = pywikibot.Category(site, 'Disambiguation')
disamb_pages = [article.title() for article in disamb_cat.articles()]

db = MySQLdb.connect(
    host=settings.get('db', 'host'),
    user=settings.get('db', 'username'),
    passwd=settings.get('db', 'password'),
    db=settings.get('db', 'database'),
    charset='utf8'
)

try: # Not using CREATE TABLE IF EXISTS to avoid MySQL warning if indeed exists
    table_cur = db.cursor()
    table_cur.execute(
        'CREATE TABLE hitchwiki_migrate.migrated_articles (' +
            ' page_id integer NOT NULL PRIMARY KEY' +
        ')'
    )
except MySQLdb.Error, e:
    if e.args[0] != 1050:
        raise
    # otherwise, error code 1050: table already exists; we just move on

count = 0
for page in gen:
    print '#%d. %s' % (count + 1, page.title().encode('utf-8'))
    print 'http://' + settings.get('general', 'domain') + '/en/' + page.title(asUrl=True)
    print

    if page.isRedirectPage():
        print "Skip: redirect page"
        print
    elif page.title() in disamb_pages:
        print "Skip: disabmiguation page"
        print
    else:
        # Get page id (_pageid isn't to be relied upon, but thank Thor it works)
        page.get()
        pageid = page._pageid

        # Check if the article has possibly already been migrated
        table_cur = db.cursor()
        table_cur.execute((
            'SELECT 1' +
                ' FROM hitchwiki_migrate.migrated_articles' +
                ' WHERE page_id = %s'
        ) % (pageid))

        if table_cur.rowcount != 0:
            print "Skip: already migrated"
            print
        else: # Keep goin'
            entity = None
            properties = None

            # Remove <map /> tags from page text
            new_text = page.text
            new_text = re.sub(map_link_regex, '', new_text)

            # Remove infoboxes from page text
            infoboxes = re.findall(infobox_code_regex, new_text, flags=re.DOTALL)
            for infobox in infoboxes:
                curly_braces = re.findall('{{', infobox)
                if len(curly_braces) > 1:
                    print "Warning: infobox with nested template; skip cutting"
                    print
                else:
                    new_text = re.sub(infobox_code_regex, '', new_text, flags=re.DOTALL)
            lendiff = len(page.text) - len(new_text)

            # ==================================================================
            # ========== {Area Type=Road} ======================================
            # ==================================================================

            if re.match(article_title_road_regex, page.title()):
                print 'Use {{Area Type=Road}} template'
                print

                # Has no relevant info in GeoNames, use only Google Geocode
                google_data = google_geocode.lookup(page.title())
                if google_data['results'] and 'route' in google_data['results'][0]['types']:
                    location = google_data['results'][0]['geometry']['location']
                    viewport = google_data['results'][0]['geometry']['viewport']
                    address = google_data['results'][0]['address_components']
                    country = next(component["long_name"] for component in address if "country" in component["types"])
                    entity = 'Area'
                    properties = {
                        'Type': 'Road',
                        'Location': '%s,%s' % (location['lat'], location['lng']),
                        'Bbox': "%s,%s,%s,%s" % (viewport['southwest']['lng'], viewport['southwest']['lat'], viewport['northeast']['lng'], viewport['northeast']['lat']),
                        'Countries': country
                    }

            # ==================================================================
            # ========== {Area Type=Border crossing} ===========================
            # ==================================================================

            elif re.match(article_title_border_regex, page.title()):
                print 'Use {{Area Type=Border crossing}} template'
                print

                # Has no relevant info in GeoNames, use only Google Geocode
                google_data = google_geocode.lookup(page.title())
                if google_data['results']:
                    location = google_data['results'][0]['geometry']['location']
                    viewport = google_data['results'][0]['geometry']['viewport']
                    address = google_data['results'][0]['address_components']
                    country = next(component["long_name"] for component in address if "country" in component["types"])
                    entity = 'Area'
                    properties = {
                        'Type': 'Border Crossing',
                        'Location': '%s,%s' % (location['lat'], location['lng']),
                        'Bbox': "%s,%s,%s,%s" % (viewport['southwest']['lng'], viewport['southwest']['lat'], viewport['northeast']['lng'], viewport['northeast']['lat']),
                        'Countries': country
                    }

            # ==================================================================

            else:
                # For all other scenarios (not Road or Border crossing), use
                # a combination GeoNames and Google Geocode
                geonames_data = geonames.lookup(page.title())
                if geonames_data["totalResultsCount"] > 0:
                    geonames_result = geonames_data['geonames'][0]
                    relevant = (page.title() in config['whitelist'] or geonames_result['score'] >= config['score_threshold'])
                    if relevant and page.title() not in config['blacklist']:
                        properties = {
                            'Location': '%s,%s' % (geonames_result['lat'], geonames_result['lng'])
                        }

                        # Move all the text on top of the first header to the Semantic template
                        if new_text.startswith("=="):
                            first_header_pos = 0
                        else:
                            first_header_pos = new_text.find("\n==")
                            if first_header_pos == -1:
                                first_header_pos = len(new_text)
                        introduction = new_text[0:first_header_pos]
                        new_text = new_text[first_header_pos:]

                        # All three relevant templates (City, Country and Area) contain Introduction property
                        properties['Introduction'] = introduction

                        # Get bounding box
                        google_data = google_geocode.lookup(page.title())
                        if google_data['results']:
                            viewport = google_data['results'][0]['geometry']['viewport']
                            properties['Bbox'] = '%s,%s,%s,%s' % (viewport['southwest']['lng'], viewport['southwest']['lat'], viewport['northeast']['lng'], viewport['northeast']['lat'])
                        elif 'bbox' in geonames_result: # GeoNames bbox sucks for countries like France with remote islands, so only use as a fallback strategy
                            bbox = geonames_result['bbox']
                            properties['Bbox'] = '%s,%s,%s,%s' % (bbox['west'], bbox['south'], bbox['east'], bbox['north'])
                        else:
                            properties['Bbox'] = ''

                        # ======================================================
                        # ========== {{Country}} ===============================
                        # ======================================================

                        if geonames_result['fcl'] == 'A' and 'fcode' in geonames_result and geonames_result['fcode'] in ['PCL', 'PCLI', 'PCLF']:
                            print 'Use {{Country}} template'
                            print

                            entity = 'Country'

                            # look for Capital in the removed Infoboxes
                            capital_lists = re.findall('(\|capital\s*=\s*)(.*)', page.text)
                            if len(capital_lists) > 1:
                                print 'Warning: multiple "capital" definitions; ignore all'
                                print
                            elif len(capital_lists) == 1:
                                capital = capital_lists[0][1].strip()
                                capital = re.sub('\[\[', '', re.sub('\]\]', '', re.sub('\|.*', '', capital))).strip() # extract page title from page link, if needed
                            else:
                                capital = ''

                            # look for Languages in the removed Infoboxes
                            language_lists = re.findall('(\|language\s*=\s*)(.*)', page.text)
                            if len(language_lists) > 1:
                                print 'Warning: multiple "language" definitions; ignore all'
                                print
                            elif len(language_lists) == 1:
                                languages = language_lists[0][1].strip()
                            else:
                                languages = ''

                            # look for Currency in the removed Infoboxes
                            currency_lists = re.findall('(\|currency\s*=\s*)(.*)', page.text)
                            if len(currency_lists) > 1:
                                print 'Warning: multiple "currency" definitions; ignore all'
                                print
                            elif len(currency_lists) == 1:
                                currency = currency_lists[0][1].strip()
                            else:
                                currency = ''

                            properties.update({
                                'CountryCode': geonames_result["countryCode"],
                                'Population': geonames_result['population'],
                                'Capital': capital,
                                'Languages': languages,
                                'Currency': currency
                            })

                        # ======================================================
                        # ========== {{City}} ==================================
                        # ======================================================

                        elif geonames_result['fcl'] == 'P':
                                print 'Use {{City}} template'
                                print

                                entity = 'City'

                                # look for MajorRoads in the removed Infoboxes
                                motorway_lists = re.findall('(\|motorways\s*=\s*)(.*)', page.text)
                                if len(motorway_lists) > 1:
                                    print 'Warning: multiple "motorways" definitions; ignore all'
                                    print
                                elif len(motorway_lists) == 1:
                                    motorways = ", ".join([
                                        # extract page title from page link and remove visible alias, if needed
                                        re.sub('\[\[', '', re.sub('\]\]', '', re.sub('\|.*', '', motorway))).strip()
                                        for motorway
                                        in motorway_lists[0][1].split(',')
                                    ])
                                else:
                                    motorways = ''

                                # look for LicensePlate in the removed Infoboxes
                                plate_lists = re.findall('(\|plate\s*=\s*)(.*)', page.text)
                                if len(plate_lists) > 1:
                                    print 'Warning: multiple "plate" definitions; ignore all'
                                    print
                                elif len(plate_lists) == 1:
                                    plate = plate_lists[0][1].strip()
                                    if plate == '-':
                                        plate = ''
                                else:
                                    plate = ''

                                properties.update({
                                    'Country': geonames_result['countryName'],
                                    'AdministrativeDivision': geonames_result['adminName1'],
                                    'Population': geonames_result['population'],
                                    'LicensePlate': plate,
                                    'MajorRoads': motorways
                                })

                        # ======================================================

                        else:
                            properties['Countries'] = geonames_result['countryName']

                            # ==================================================
                            # ========== {{Area Type=Continent}} ===============
                            # ==================================================

                            if geonames_result['fcl'] == 'L' and geonames_result['fcode'] == 'CONT': # continent
                                print 'Use {{Area Type=Continent}} template'
                                print

                                entity = 'Area'
                                properties['Type'] = 'Continent'

                            # ==================================================
                            # ========== {{Area Type=Region}} ==================
                            # ==================================================

                            elif (
                                geonames_result['fcl'] == 'A' # administrative division
                                or (geonames_result['fcl'] == 'T' and geonames_result['fcode'] in ['ISL', 'ISLS']) # island(s)
                                or (geonames_result['fcl'] == 'L' and geonames_result['fcode'] == 'RGN')  # region
                            ):
                                print 'Use {{Area Type=Region}} template'
                                print

                                entity = 'Area'
                                properties['Type'] = 'Region'

                            # ==================================================
                            # ========== {{Area Type=Airport}} =================
                            # ==================================================

                            elif geonames_result['fcl'] == 'S' and geonames_result['fcode'] == 'AIRP': # airport
                                print 'Use {{Area Type=Airport}} template'
                                print

                                entity = 'Area'
                                properties['Type'] = 'Airport'

                            # ==================================================

            if entity:
                # Join property values to get Semantic template code (careful with Unicode); prepend it to the article
                smw_code = "{{%s\n|%s\n}}" % (entity, "\n|".join(['%s=%s' % (unicode(k).encode('utf-8'), unicode(v).encode('utf-8')) for k, v in properties.items()]))
                smw_code = smw_code.decode('utf-8')
                new_text = smw_code + new_text

                # Show what's being changed
                diff = unified_diff(page.text.splitlines(1), new_text.splitlines(1))
                print ''.join(diff)

                try:
                    page.text = new_text
                    page.save()

                    # On success, insert page_id into article migration logging table
                    table_cur = db.cursor()
                    table_cur.execute(
                        'INSERT INTO hitchwiki_migrate.migrated_articles (page_id)' +
                            " VALUES (%s)" % (pageid)
                    )
                    db.commit()
                except:
                    raise

            else:
                print 'Skip: not a location'
                print

    print "-------------------------------------------------------------------------------"
    print
    count += 1

print 'Total:', count
