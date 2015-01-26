import urllib
import json
from lib.cachedhttprequest import CachedHttpRequest

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
