import pywikibot
from pywikibot import pagegenerators
import json, requests, urllib # geopy is too limited ;(
import re, hashlib
import os.path

class CachedHttpRequest:
    @staticmethod
    def request(url, cache_dir):
        hash = hashlib.md5(url).hexdigest()
        filename = cache_dir + '/' + hash
        if (os.path.isfile(filename)):
            #print 'Loading cache for %s from %s' % (url, filename)
            with open(filename, 'r') as cache_file:
                content = cache_file.read().decode('utf-8')
        else:
            #print 'Saving cache for %s into %s' % (url, filename)
            content = requests.get(url=url).text
            with open(filename, 'w') as cache_file:
                cache_file.write(content.encode('utf-8'))
        return content

class GeoNames(object):
    def __init__(self, username, cache_dir):
        self.url = 'http://api.geonames.org/searchJSON'
        self.default_params = dict(
            formatted='true',
            maxRows=10,
            lang='en',
            username=username,
            style='full'
        )
        self.cache_dir = cache_dir

    def lookup(self, query):
        params = self.default_params.copy()
        params['q'] = query.encode('utf-8')
        url = self.url + '?' + urllib.urlencode(params)
        return json.loads(CachedHttpRequest.request(url, self.cache_dir))

class GoogleGeocode(object):
    def __init__(self, cache_dir):
        self.url = 'https://maps.googleapis.com/maps/api/geocode/json'
        self.default_params = dict()
        self.cache_dir = cache_dir

    def lookup(self, query):
        params = self.default_params.copy()
        params['address'] = query.encode('utf-8')
        url = self.url + '?' + urllib.urlencode(params)
        txt = CachedHttpRequest.request(url, self.cache_dir)
        return json.loads(txt)

with open('config.json') as config_file:    
    config = json.load(config_file)

motorway_regex = '[A-Z]?-?\d+\s*(\((\w|\s)+\))'
border_regex = '.*border (crossing|checkpoint)'

geonames = GeoNames('hitchwiki', './.cache')
google_geocode = GoogleGeocode('./.cache')

site = pywikibot.Site()
gen = pagegenerators.AllpagesPageGenerator(site=site)
disamb_cat = pywikibot.Category(site, 'Disambiguation')
disamb_pages = [article.title() for article in disamb_cat.articles()]

count = 0
for page in gen:
    if not page.isRedirectPage() and page.title() not in disamb_pages:
        print '#%d. %s' % (count + 1, page.title().encode('utf-8'))
        print 'http://hitchwiki.org/en/' + page.title(asUrl=True)

        entity = None
        properties = None

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
                    'Type': 'Border rCossing',
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
                            entity = 'City'
                            properties.update({
                                'Country': geonames_result['countryName'],
                                'Population': geonames_result['population'],
                                'LicensePlate': '',
                                'MajorRoads': ''
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
            print "{{%s\n|%s\n}}" % (entity, "\n|".join(['%s=%s' % (unicode(k).encode('utf-8'), unicode(v).encode('utf-8')) for k, v in properties.items()]))
        else:
            print '-'
        print
        #page.text = page.text.replace('foo', 'bar')
        #page.save('Replacing "foo" with "bar"')  # Saves the page
        count += 1

print 'total: ', count
