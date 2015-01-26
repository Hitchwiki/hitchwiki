import pywikibot
import json, requests, urllib
import hashlib
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

class OldHitchwikiMaps(object):
    def __init__(self, cache_dir):
        self.url = 'http://hitchwiki.org/maps/api/'
        self.default_params = dict()
        self.cache_dir = cache_dir

    def allspots(self):
        params = self.default_params.copy()
        params['bounds'] = "-90,90,-180,180".encode('utf-8')
        url = self.url + '?' + urllib.urlencode(params)
        return json.loads(CachedHttpRequest.request(url, self.cache_dir))

    def spotinfo(self, spot_id):
        params = self.default_params.copy()
        params['place'] = spot_id
        url = self.url + '?' + urllib.urlencode(params)
        return json.loads(CachedHttpRequest.request(url, self.cache_dir))

site = pywikibot.Site()
oldhwmaps = OldHitchwikiMaps('./.cache')
spots = oldhwmaps.allspots()

count = 0
dummy_user_id = 0
for spot in spots:
    print spot['id'], spot['lat'], spot['lon'], spot['rating']
    spotinfo = oldhwmaps.spotinfo(spot['id'])

    #print '#%d. %s' % (count + 1, page.title().encode('ascii', 'ignore'))
    #print 'http://hitchwiki.org/en/' + page.title(asUrl=True)

    print 'saving spot'
    title = 'Spot %s (%s %s)' % (spot['id'], spot['lat'], spot['lon'])
    page = pywikibot.Page(site, title)
    page.text = (
        "{{Spot\n" +
        ("|Description=%s\n" % spotinfo["description"]["en_UK"]) +
        "|Cities=\n" +
        "|Country=\n" +
        "|CardinalDirection=\n" +
        "|CitiesDirection=\n" +
        "|RoadsDirection=\n" +
        ("|Location=%s, %s\n" % (spot['lat'], spot['lon'])) +
        "}}"
    )
    page.save()
    page.get()
    print page._pageid
    break

    for comment in spotinfo['comments']:
        try:
            user_id = comment['user']['id']
        except:
            user_id = dummy_user_id
        newhw.add_comment(comment['comment'], comment['datetime'], user_id)



    break

    print
    #page.text = page.text.replace('foo', 'bar')
    #page.save('Replacing "foo" with "bar"')  # Saves the page
    count += 1

print 'total: ', count
