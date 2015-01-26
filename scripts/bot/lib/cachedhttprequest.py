import hashlib
import os.path
import requests

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
