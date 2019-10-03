*****This seems deprecated*****


# Hitchwiki
_The Hitchhiker's Guide to Hitchhiking the World_

[Hitchwiki](http://hitchwiki.org/) is a collaborative website for gathering information about [hitchhiking](http://hitchwiki.org/en/Hitchhiking) and other ways of extremely cheap ways of transport. It is maintained by many active hitchhikers all around the world. We have information about how to hitch out of big cities, how to cover long distances, maps and many more tips.

# Development howto
- See [INSTALL.md](https://github.com/Hitchwiki/hitchwiki/blob/ansible/INSTALL.md) and [this ticket](https://github.com/Hitchwiki/hitchwiki/issues/172) to set up the [backend](https://github.com/Hitchwiki/hitchwiki/issues?q=is%3Aissue+is%3Aopen+label%3Abackend) with [Ansible](https://github.com/Hitchwiki/hitchwiki/tree/master/scripts/ansible).
- To tweak the [frontend](https://github.com/Hitchwiki/hitchwiki/issues?q=is%3Aissue+is%3Aopen+label%3Afrontend), use the browser specific development tools.

## Configs
* Everything is under `./configs`

## Import/export SemanticWiki pages
* Pages are listed at `./scripts/pages/_pagelist.txt`.
* Run `sh ./scripts/import.sh` to _import_ pages (currently does this only for dev Vagrant).
* Run `sh ./scripts/export.sh` to _export_ pages (currently does this only for dev Vagrant).
* By default import/export script will process all the pages listed at _pagelist.txt, but if you need just one page, call script with pagename, for example: `sh ./scripts/import.sh "Form:Spot"`.

## Adding new language
* Add it to `./configs/languages.ini`
* Run `sh scripts/language.sh code` where `code` is two letter language code, eg. `de` for Germany

-------------------------------------


*****This seems deprecated*****

--------


# Hitchwiki API

_Note that this documentation refers to development version and isn't live yet._

You might find [these libraries](https://www.mediawiki.org/wiki/API:Client_code) useful.

### MW API
Hitchwiki works trough MediaWiki API so reading [their documentation](https://www.mediawiki.org/wiki/API:Main_page) first helps a lot.
* End point: `http://hitchwiki.org/en/api.php`
* [API Sandbox](https://www.mediawiki.org/wiki/Extension:ApiSandbox): [http://hitchwiki.org/en/Special:ApiSandbox](http://hitchwiki.org/en/Special:ApiSandbox)

### Ask API
Most of the contents are structured with [Semantic Mediawiki](https://www.semantic-mediawiki.org/) so we also have their “[Ask API](http://semantic-mediawiki.org/wiki/Ask_API)” in use, which uses [Semantic search](https://semantic-mediawiki.org/wiki/Help:Semantic_search) features.
* End point: `http://hitchwiki.org/en/api.php?action=ask&query=`
* Query builder form: [http://hitchwiki.org/en/Special:Ask](http://hitchwiki.org/en/Special:Ask)

### Authenticate
* See https://www.mediawiki.org/wiki/API:Login

# Development API
Use `.dev` instead of `.org` to use same end points with your local development environment.

# Examples

#### Bounding box
```
http://hitchwiki.dev/en/api.php?action=hwmapapi&SWlat=-45&SWlon=-183&NElat=82&NElon=323&format=json
```

Gives you spots, cities and countries with article ID, category, location and [hitchability](#hitchability) rating of the spot (0-5). 

Result example:
```json
{
    "query": {
        "spots": [{
            "id": "16",
            "location": ["-30.6143", "24.9609"],
            "category": "Spots",
            "average_rating": "4"
        }, {
            "id": "17",
            "location": ["37.0069", "105.117"],
            "category": "Spots",
            "average_rating": "3"
        }]
    }
}
```

You might find [boundingbox tool](http://boundingbox.klokantech.com/) useful.

#### Place
* _To be documented_

# Hitchability codes and colors
| Code | Color     | Verbal    |
|------|-----------|-----------|
| 0    | `#7F7F7F` | no rating |
| 1    | `#BC2C00` | senseless |
| 2    | `#E57800` | bad       |
| 3    | `#A09800` | average   |
| 4    | `#547A2F` | good      |
| 5    | `#165E19` | very-good |

You can use [same graphics](https://github.com/Hitchwiki/hitchwiki-graphics/tree/master/map-icons/hh-spot) as we use to present spots.

# Custom HW spot comment API

### Add comment to a spot

URL: `/en/api.php?action=hwaddcomment&format=json`

POST data:
```json
{
  "commenttext": "cool beans of a spot!\nwaited '''4 hours''', and got picked by a camel",
  "pageid": "1",
  "token": "89bd6435cc9fe5030091b816d8d53432+\"
}
```

Response:
```json
{
    "query": {
        "count": 2,
        "pageid": 1,
        "comment_id": 9146,
        "timestamp": "20150206110646"
    }
}
```

### Delete a comment of a spot

URL: `/en/api.php?action=hwaddcomment&format=json`

POST data:
```json
{
  "comment_id": 9146,
  "token": "89bd6435cc9fe5030091b816d8d53432+\"
}
```

Response:
```json
{
    "query": {
        "count": 1,
        "pageid": 1
    }
}
```

### Get comments for a spot

URL: `/en/api.php?action=hwgetcomments&format=json&pageid=1&dontparse=0`

Response:
```json
{
    "query": {
        "comments": [
            {
                "pageid": 1,
                "comment_id": 9145,
                "commenttext": "<p>new comment here!\n</p>",
                "timestamp": "20150206102722",
                "user_id": 0,
                "user_name": ""
            },
            {
                "pageid": 1,
                "comment_id": 9147,
                "commenttext": "<p>cool beans of a spot!\\nwaited <b>4 hours</b>, and got picked by a camel\n</p>",
                "timestamp": "20150206112401",
                "user_id": 22474,
                "user_name": "Hitchbot"
            }
        ]
    }
}
```

### Get comment counts for one or more spots

URL: `/en/api.php?action=hwgetcommentscount&format=json&pageid=1%7C17256`

`%7C` stands for `|` (the vertical bar/pipe character)

Response:
```json
{
    "query": {
        "comment_counts": [
            {
                "pageid": 1,
                "comment_count": 2
            },
            {
                "pageid": 17256,
                "comment_count": 7
            }
        ]
    }
}
```

# Custom HW spot/country rating API

### Add rating to spot/country

URL: `/en/api.php?action=hwaddrating&format=json`

POST data:
```json
{
  "pageid": 21650,
  "rating": 5,
  "token": "89bd6435cc9fe5030091b816d8d53432+\"
}
```

Response:
```json
{
    "query": {
        "average": 4.33,
        "count": 3,
        "pageid": 21650,
        "timestamp": "20150206115456"
    }
}
```

### Delete a rating of a spot/country

URL: `/en/api.php?action=hwdeleterating&format=json`

POST data:
```json
{
  "pageid": 21650,
  "token": "89bd6435cc9fe5030091b816d8d53432+\"
}
```

Response:
```json
{
    "query": {
        "average": 4,
        "count": 2,
        "pageid": 21650
    }
}
```

### Get ratings for a spot/country

URL: `/en/api.php?action=hwgetratings&format=json&pageid=21650`

Response:
```json
{
    "query": {
        "ratings": [
            {
                "pageid": 21650,
                "rating": 4,
                "timestamp": "20120721175348",
                "user_id": 5510,
                "user_name": "F.arbolino"
            },
            {
                "pageid": 21650,
                "rating": 4,
                "timestamp": "20131027194121",
                "user_id": 11444,
                "user_name": "Sorokin"
            },
            {
                "pageid": 21650,
                "rating": 5,
                "timestamp": "20150206115456",
                "user_id": 22474,
                "user_name": "Hitchbot"
            }
        ],
        "distribution": {
            "1": {
                "count": 0,
                "percentage": 0
            },
            "2": {
                "count": 0,
                "percentage": 0
            },
            "3": {
                "count": 0,
                "percentage": 0
            },
            "4": {
                "count": 2,
                "percentage": 66.667
            },
            "5": {
                "count": 1,
                "percentage": 33.333
            }
        }
    }
}
```

### Get average ratings for one or more spots/countries

URL: `/en/api.php?action=hwavgrating&format=json&pageid=21650%7C12952&user_id=22474`

Response:
```json
{
    "query": {
        "ratings": [
            {
                "pageid": 12952,
                "rating_average": 4,
                "rating_count": 1,
                "rating_user": -1,
                "timestamp_user": ""
            },
            {
                "pageid": 21650,
                "rating_average": 4.33,
                "rating_count": 3,
                "rating_user": 5,
                "timestamp_user": "20150206115456"
            }
        ]
    }
}
```

# Custom HW spot waiting time API

### Add waiting time to a spot

URL: `/en/api.php?action=hwaddwaitingtime&format=json`

POST data:
```json
{
  "pageid": 21650,
  "waiting_time": 15,
  "token": "89bd6435cc9fe5030091b816d8d53432+\"
}
```

Response:
```json
{
    "query": {
        "average": 13,
        "min": 10,
        "max": 15,
        "count": 2,
        "pageid": 21650,
        "waiting_time_id": 20746,
        "timestamp": "20150206125208"
    }
}
```

### Delete a waiting time of a spot

URL: `/en/api.php?action=hwdeletewaitingtime&format=json`

POST data:
```json
{
  "waiting_time_id": 20746,
  "token": "89bd6435cc9fe5030091b816d8d53432+\"
}
```

Response:
```json
{
    "query": {
        "average": 10,
        "min": 10,
        "max": 10,
        "count": 1,
        "pageid": 21650
    }
}
```

### Get waiting times for a spot

URL: `/en/api.php?action=hwgetwaitingtimes&format=json&pageid=21650`

Response:
```json
{
    "query": {
        "waiting_times": [
            {
                "pageid": 21650,
                "waiting_time_id": 5648,
                "waiting_time": 10,
                "timestamp": "20120721175357",
                "user_id": 5510,
                "user_name": "F.arbolino"
            },
            {
                "pageid": 21650,
                "waiting_time_id": 20746,
                "waiting_time": 15,
                "timestamp": "20150206125208",
                "user_id": 22474,
                "user_name": "Hitchbot"
            }
        ],
        "distribution": [
            {
                "count": 2,
                "percentage": 100
            },
            {
                "count": 0,
                "percentage": 0
            },
            {
                "count": 0,
                "percentage": 0
            },
            {
                "count": 0,
                "percentage": 0
            }
        ]
    }
}
```

### Get average waiting time for one or more spots

URL: `/en/api.php?action=hwavgwaitingtime&format=json&pageid=21650%7C12952`

Response:
```json
{
    "query": {
        "waiting_times": [
            {
                "pageid": 21650,
                "waiting_time_average": 13,
                "waiting_time_min": 10,
                "waiting_time_max": 15,
                "waiting_time_count": 2
            }
        ]
    }
}
```


