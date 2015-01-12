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
            print 'Loading cache for %s from %s' % (url, filename)
            with open(filename, 'r') as cache_file:
                content = cache_file.read().decode('utf-8')
        else:
            print 'Saving cache for %s into %s' % (url, filename)
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
        params['q'] = query
        url = self.url + '?' + urllib.urlencode(params)
        return json.loads(CachedHttpRequest.request(url, self.cache_dir))

class GoogleGeocode(object):
    def __init__(self, cache_dir):
        self.url = 'https://maps.googleapis.com/maps/api/geocode/json'
        self.default_params = dict()
        self.cache_dir = cache_dir

    def lookup(self, query):
        params = self.default_params.copy()
        params['address'] = query
        url = self.url + '?' + urllib.urlencode(params)
        txt = CachedHttpRequest.request(url, self.cache_dir)
        return json.loads(txt)

scoreThreshold = 24 # magic!
relevanceFilter = [
    {'fcl': 'L', 'fcode': 'CONT'}, # continent
    {'fcl': 'S', 'fcode': 'AIRP'}, # airport
    {'fcl': 'L', 'fcode': 'RGN'}, # region
    {'fcl': 'T', 'fcode': 'ISL'}, # island
    {'fcl': 'T', 'fcode': 'ISLS'}, # islands
    {'fcl': 'A'}, # country or administrative division
    {'fcl': 'P'} # city or village
]
motorway_regex = '[A-Z]?-?\d+\s*(\((\w|\s)+\))'
border_regex = '.*border (crossing|checkpoint)'

geonames = GeoNames('hitchwiki', '/tmp/hw-migrate-cache')
google_geocode = GoogleGeocode('/tmp/hw-migrate-cache')

site = pywikibot.Site()
gen = pagegenerators.AllpagesPageGenerator(site=site)
disamb_cat = pywikibot.Category(site, 'Disambiguation')
disamb_page_titles = [article.title() for article in disamb_cat.articles()]

count = 0
for page in gen:
    if not page.isRedirectPage() and page.title() not in disamb_page_titles:
        print '#%d. %s' % (count + 1, page.title().encode('ascii', 'ignore'))
        print 'http://hitchwiki.org/en/' + page.title(asUrl=True)

        if not re.match(motorway_regex, page.title()) and not re.match(border_regex, page.title()): # no motorway info in GeoNames DB
            data = geonames.lookup(page.title())

            if (
                data["totalResultsCount"] > 0
                and data['geonames'][0]['score'] >= scoreThreshold
                and any(all(item in data['geonames'][0].items() for item in filter.items()) for filter in relevanceFilter)
            ):
                print 'GeoNames name: %s' % (data['geonames'][0]['name'].encode('ascii', 'ignore'))
                print 'GeoNames Location: %s %s' % (
                    data['geonames'][0]['lat'],
                    data['geonames'][0]['lng']
                )
                if 'bbox' in data['geonames'][0]:
                    print 'GeoNames bounding box: %s %s - %s %s' % (
                        data['geonames'][0]['bbox']['north'],
                        data['geonames'][0]['bbox']['west'],
                        data['geonames'][0]['bbox']['south'],
                        data['geonames'][0]['bbox']['east']
                    )
                else:
                    print 'No bounding box data in GeoNames DB'

                google_data = google_geocode.lookup(page.title())
                if google_data['results']:
                    print 'Google Geocode bounding box: %s %s - %s %s' % (
                        google_data['results'][0]['geometry']['viewport']['northeast']['lat'],
                        google_data['results'][0]['geometry']['viewport']['southwest']['lng'],
                        google_data['results'][0]['geometry']['viewport']['southwest']['lat'],
                        google_data['results'][0]['geometry']['viewport']['northeast']['lng']
                    )
                else:
                    print 'No Google Geocode viewport data'
            else:
                print '-'
        else: # use Google Geocode for motorway and border crossing lookup
            google_data = google_geocode.lookup(page.title())
            if google_data['results']:
                print 'Google GeoCode bounding box: %s %s - %s %s' % (
                    google_data['results'][0]['geometry']['viewport']['northeast']['lat'],
                    google_data['results'][0]['geometry']['viewport']['southwest']['lng'],
                    google_data['results'][0]['geometry']['viewport']['southwest']['lat'],
                    google_data['results'][0]['geometry']['viewport']['northeast']['lng']
                )

        print
        #page.text = page.text.replace('foo', 'bar')
        #page.save('Replacing "foo" with "bar"')  # Saves the page
        count += 1

print 'total: ', count
