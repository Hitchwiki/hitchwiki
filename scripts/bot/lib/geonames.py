import urllib
import json
from lib.cachedhttprequest import CachedHttpRequest

#
# geopy is too limited ;(
# hence this custom implementation
#

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
