#
# Add Semantic MediaWiki templates to articles that (supposedly) correspond to geographic locations
# There are 4 location templates: Area, City, Country, Spot (all can be found in /scripts/pages/)
# This script handles the first three
#

# Allow imports from parent dir
import os,sys,inspect
currentdir = os.path.dirname(os.path.abspath(inspect.getfile(inspect.currentframe())))
parentdir = os.path.dirname(currentdir)
sys.path.insert(0,parentdir)

import pywikibot
from pywikibot import pagegenerators

import re
import json
import ConfigParser

from lib.geonames import GeoNames
from lib.googlegeocode import GoogleGeocode

settings = ConfigParser.ConfigParser()
settings.read('../../configs/settings.ini')

with open('config.json') as config_file:
    config = json.load(config_file)

motorway_regex = '[A-Z]?-?\d+\s*(\((\w|\s)+\))'
border_regex = '.*border (crossing|checkpoint)'
map_code_regex = '<map[^>]+>'
infobox_regex = '(?i){{infobox.*}}'

geonames = GeoNames(settings.get('vendor', 'geonames_username'), './.cache')
google_geocode = GoogleGeocode('./.cache')

site = pywikibot.Site()
gen = pagegenerators.AllpagesPageGenerator(site=site)
disamb_cat = pywikibot.Category(site, 'Disambiguation')
disamb_pages = [article.title() for article in disamb_cat.articles()]

count = 0
for page in gen:
    if not page.isRedirectPage() and page.title() not in disamb_pages:
        print '#%d. %s' % (count + 1, page.title().encode('utf-8'))
        print 'http://' + settings.get('general', 'domain') + '/en/' + page.title(asUrl=True)

        # Uncomment to resume from speciffic point
	#if count < 3055:
        #    count += 1
        #    continue

        entity = None
        properties = None

        # remove <map /> tags from page text
        new_text = page.text
        new_text = re.sub(map_code_regex, '', new_text)
        new_text = re.sub(infobox_regex, '', new_text, flags=re.DOTALL)
        lendiff = len(page.text) - len(new_text)
        if lendiff:
            print ('# removed <map /> tags and infoboxes: %d characters' % lendiff)

        if re.match(motorway_regex, page.title()): # {Area Type=Road} (no relevant info in GeoNames DB)
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
        elif re.match(border_regex, page.title()): # {Area Type=Border crossing} (no relevant info in GeoNames DB)
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
        else:
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

                    properties['Introduction'] = introduction

                    google_data = google_geocode.lookup(page.title())
                    if google_data['results']:
                        viewport = google_data['results'][0]['geometry']['viewport']
                        properties['Bbox'] = '%s,%s,%s,%s' % (viewport['southwest']['lng'], viewport['southwest']['lat'], viewport['northeast']['lng'], viewport['northeast']['lat'])
                    elif 'bbox' in geonames_result: # bbox sucks for countries like France with remote islands, so only use as a fallback strategy
                        bbox = geonames_result['bbox']
                        properties['Bbox'] = '%s,%s,%s,%s' % (bbox['west'], bbox['south'], bbox['east'], bbox['north'])
                    else:
                        properties['Bbox'] = ''

                    if geonames_result['fcl'] == 'A' and 'fcode' in geonames_result and geonames_result['fcode'] in ['PCL', 'PCLI', 'PCLF']: # {{Country}}
                        entity = 'Country'
                        properties.update({
                            'Population': geonames_result['population'],
                            'Capital': '',
                            'Currency': ''
                        })
                    elif geonames_result['fcl'] == 'P': # {{City}}
                            # looks for MajorRoads and LicensePlate in the removed Infobox
                            motorway_lists = re.findall('(\|motorways\s*=\s*)(.*)', page.text)
                            if len(motorway_lists) > 1:
                                print 'Error: more than one motorway list found'
                            elif len(motorway_lists) == 1:
                                motorways = ", ".join([
                                    re.sub('\[\[', '', re.sub('\|.*', '', motorway)).strip()
                                    for motorway
                                    in motorway_lists[0][1].split(',')
                                ])
                            else:
                                motorways = ''

                            entity = 'City'
                            properties.update({
                                'Country': geonames_result['countryName'],
                                'AdministrativeDivision': geonames_result['adminName1'],
                                'Population': geonames_result['population'],
                                'LicensePlate': '',
                                'MajorRoads': motorways
                            })
                    else: # {{Area}}
                        properties['Countries'] = geonames_result['countryName']
                        if geonames_result['fcl'] == 'L' and geonames_result['fcode'] == 'CONT': # continent
                            entity = 'Area'
                            properties['Type'] = 'Continent'
                        elif (
                            geonames_result['fcl'] == 'A' # administrative division
                            or (geonames_result['fcl'] == 'T' and geonames_result['fcode'] in ['ISL', 'ISLS']) # island(s)
                            or (geonames_result['fcl'] == 'L' and geonames_result['fcode'] == 'RGN')  # region
                        ):
                            entity = 'Area'
                            properties['Type'] = 'Region'
                        elif geonames_result['fcl'] == 'S' and geonames_result['fcode'] == 'AIRP': # airport
                            entity = 'Area'
                            properties['Type'] = 'Airport'

        if entity:
            smw_code = "{{%s\n|%s\n}}" % (entity, "\n|".join(['%s=%s' % (unicode(k).encode('utf-8'), unicode(v).encode('utf-8')) for k, v in properties.items()]))
            smw_code = smw_code.decode('utf-8')
            print smw_code
            #print repr(new_text)
            #print 'smv', repr(smw_code)
            new_text = smw_code + new_text

            page.text = new_text
            page.save()
        else:
            print '-'
        print
        count += 1

print 'total: ', count
