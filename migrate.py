import pywikibot
from pywikibot import pagegenerators
import json, requests # geopy is too limited ;(
import re

site = pywikibot.Site('en', 'hitchwiki')
gen = pagegenerators.AllpagesPageGenerator(site=site)

url = 'http://api.geonames.org/searchJSON'

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
defaultParams = dict(
    formatted='true',
    maxRows=10,
    lang='en',
    username='hitchwiki',
    style='full'
)

count = 0
for page in gen:
	print '#%d. %s' % (count + 1, page.title().encode('ascii', 'ignore'))
	print 'http://hitchwiki.org/en/' + page.title(asUrl=True)

	if not re.match('[A-Z]?-?\d+\s*(\((\w|\s)+\))', page.title().encode('ascii', 'ignore')): # no motorway info in GeoNames DB
		params = defaultParams.copy()
		params['q'] = page.title()
		resp = requests.get(url=url, params=params)
		data = json.loads(resp.text)

		if (
			data["totalResultsCount"] > 0
			and data['geonames'][0]['score'] >= scoreThreshold
			and any(all(item in data['geonames'][0].items() for item in filter.items()) for filter in relevanceFilter)
		):
			print 'GeoNames name: %s' % (data['geonames'][0]['name'].encode('ascii', 'ignore'))
			print 'Location: (%s; %s)' % (
				data['geonames'][0]['lat'],
				data['geonames'][0]['lng']
			)
			if 'bbox' in data['geonames'][0]:
				print 'Viewport: (%s; %s) - (%s; %s)' % (
					data['geonames'][0]['bbox']['west'],
					data['geonames'][0]['bbox']['north'],
					data['geonames'][0]['bbox']['east'],
					data['geonames'][0]['bbox']['south']
				)
			else:
				print 'No viewport data'
		else:
			print '-'
	else:
		print 'Motorway lookup not implemented yet'

	print
	#page.text = page.text.replace('foo', 'bar')
	#page.save('Replacing "foo" with "bar"')  # Saves the page
	count += 1

print 'total: ', count
