import pywikibot
from pywikibot import pagegenerators
import json, requests # geopy is too limited ;(
import re

class GeoNames(object):
    def __init__(self, username):
        self.url = 'http://api.geonames.org/searchJSON'
        self.default_params = dict(
            formatted='true',
            maxRows=10,
            lang='en',
            username=username,
            style='full'
        )

    def lookup(self, query):
        params = self.default_params.copy()
        params['q'] = query
        resp = requests.get(url=self.url, params=params)
        return json.loads(resp.text)

class GoogleGeocode(object):
    def __init__(self):
        self.url = 'https://maps.googleapis.com/maps/api/geocode/json'
        self.default_params = dict()

    def lookup(self, query):
        params = self.default_params.copy()
        params['address'] = query
        resp = requests.get(url=self.url, params=params)
        return json.loads(resp.text)

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

geonames = GeoNames('hitchwiki')
google_geocode = GoogleGeocode()

site = pywikibot.Site()
gen = pagegenerators.AllpagesPageGenerator(site=site)
disamb_cat = pywikibot.Category(site, 'Disambiguation')
disamb_page_titles = [article.title() for article in disamb_cat.articles()]

count = 0
for page in gen:
    if not page.isRedirectPage() and page.title() not in disamb_page_titles:
        print '#%d. %s' % (count + 1, page.title().encode('ascii', 'ignore'))
        print 'http://hitchwiki.org/en/' + page.title(asUrl=True)

        if not re.match('[A-Z]?-?\d+\s*(\((\w|\s)+\))', page.title().encode('ascii', 'ignore')): # no motorway info in GeoNames DB
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
        else: # use Google Geocode for motorway lookup
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
