<?php
class HWFindNearbyCityApi extends ApiBase {

  public function execute() {
    global $wgHwMapCityRelevanceRadius,
           $wgHwMapCityCloseDistance,
           $wgHwMapBigCityMinPopulation,
           $hwGeonamesUsername;

    // If Geonames username isn't set, return error
    if (empty($hwGeonamesUsername)) {
      $this->geocoderUnavailableAPIError();
      return true;
    }

    // Get parameters
    $params = $this->extractRequestParams();

    // Get coordinates
    // @TODO: validate lat and lng ranges to avoid unnecessary queries
    $lat = (double) $params['lat'];
    $lng = (double) $params['lng'];


    /*
     * Compute a bounding rectangle (LatLngBounds instance) from a point and a given radius.
     * Reference: http://www.movable-type.co.uk/scripts/latlong-db.html
     *
     *  -------------NE
     * |              |
     * |        radius|
     * |       o------|
     * |              |
     * |              |
     * SW-------------
     */
    // See `lib/SphericalGeometry/`
    // http://tubalmartin.github.com/spherical-geometry-php/
    // https://github.com/tubalmartin/spherical-geometry-php
    $bounds = SphericalGeometry::computeBounds(new LatLng($lat, $lng), $wgHwMapCityRelevanceRadius);
    $ne_bound = $bounds->getNorthEast();
    $sw_bound = $bounds->getSouthWest();
    $north = $ne_bound->getLat();
    $east = $ne_bound->getLng();
    $south = $sw_bound->getLat();
    $west = $sw_bound->getLng();

    // Geonames spot country lookup
    // Has to be done separately from city lookup, as the closest big city
    // can lie in a different country than the spot itself
    $response = Http::get(
      'http://api.geonames.org/findNearbyPlaceNameJSON?' .
      http_build_query(array(
        'lat' => $lat,
        'lng' => $lng,
        'username' => $hwGeonamesUsername
      ))
    );

    $country = '';

    if ($response !== false) {
      $response = json_decode($response);
      if ($response && !empty($response->geonames)) {
        $place = $response->geonames[0];
        if ($place->countryName) {
          $country = $place->countryName;
        }
      }
    }

    $this->getResult()->addValue( array(), 'country', $country );

    // Empty result set by default
    $this->getResult()->addValue( array(), 'cities', array() );

    // Query for cities within the bounding box
    $dbr = wfGetDB(DB_SLAVE);
    $res = $dbr->select(
      array(
        'geo_tags',
        'categorylinks',
        'page'
      ),
      array(
        'gt_page_id',
        'gt_lat',
        'gt_lon',
        'cl_to',
        'page_title'
      ),
      array(
        'gt_lat < ' . $north,
        'gt_lat > ' . $south,
        'gt_lon > ' . $west,
        'gt_lon < ' . $east,
        'cl_to = \'Cities\''
      ),
      __METHOD__,
      array(),
      array(
        'page' => array(
          'JOIN',
          array('page_id = cl_from')
        ),
        'categorylinks' => array(
          'JOIN',
          array('gt_page_id = cl_from')
        )
      )
    );

    $cities = array();

    foreach( $res as $row ) {
      $cities[] = array(
        'page_id' => $row->gt_page_id,
        'name' => urldecode(str_replace('_', ' ', $row->page_title)),
        // 'category' => $row->cl_to,
        'location' => array(
          floatval($row->gt_lat),
          floatval($row->gt_lon)
        ),
        // round for reliable comparison later on
        // See `lib/SphericalGeometry/`
        // http://tubalmartin.github.com/spherical-geometry-php/
        // https://github.com/tubalmartin/spherical-geometry-php
        'distance' => round(SphericalGeometry::computeDistanceBetween(
          new LatLng($row->gt_lat, $row->gt_lon),
          new LatLng($lat, $lng) // (lat; lng) from $params
        ))
      );
    }

    // Sort cities by distance
    usort($cities, function($a, $b) {
      if ($a['distance'] === $b['distance']) {
        return 0;
      }
      if ($a['distance'] < $b['distance']) {
        return -1;
      }
      return 1;
    });

    // Pick out the best city, or possibly two best cities
    $closest_cities = array();
    if (count($cities) > 0) {
      $closest_cities[] = $cities[0];

      if (count($cities) > 1) {
        if ($cities[1]['distance'] - $closest_cities[0]['distance'] <= $wgHwMapCityCloseDistance) {
          $closest_cities[] = $cities[1];
        }
      }

      $this->getResult()->addValue( array(), 'cities', $closest_cities );

      return true;
    }

    // Fall back on GeoNames when no city article has been found
    $closest_cities = array();
    $response = Http::get(
        'http://api.geonames.org/citiesJSON?' . http_build_query(array(
        'north' => $north,
        'east' => $east,
        'south' => $south,
        'west' => $west,
        'style' => 'full',
        'maxRows' => 2,
        'lang' => 'en',
        'username' => $hwGeonamesUsername
      ))
    );

    if ($response === false) {
      return true;
    }

    $response = json_decode($response);
    if (!$response || empty($response->geonames)) {
      return true;
    }

    $place = $response->geonames[0];

    if (!$this->isBigCity($place)) {
      return true;
    }

    // Add first city to the result set
    $closest_cities[] = array(
      'page_id' => 0,
      'name' => $place->name,
      'location' => array(
        floatval($place->lat),
        floatval($place->lng)
      ),
      // round for reliable comparison later on
      // See `lib/SphericalGeometry/`
      // http://tubalmartin.github.com/spherical-geometry-php/
      // https://github.com/tubalmartin/spherical-geometry-php
      'distance' => round(SphericalGeometry::computeDistanceBetween(
          new LatLng($place->lat, $place->lng),
          new LatLng($lat, $lng) // (lat; lng) from $params
      ))
    );

    $this->getResult()->addValue( array(), 'cities', $closest_cities );

    if (count($response->geonames) === 1) {
      return true;
    }

    $place = $response->geonames[1];

    // Check if the second city is a big city too
    if (!$this->isBigCity($place)) {
      return true;
    }

    $city = array(
      'page_id' => 0,
      'name' => $place->name,
      'location' => array(
        floatval($place->lat),
        floatval($place->lng)
      ),
      // round for reliable comparison later on
      // See `lib/SphericalGeometry/`
      // http://tubalmartin.github.com/spherical-geometry-php/
      // https://github.com/tubalmartin/spherical-geometry-php
      'distance' => round(SphericalGeometry::computeDistanceBetween(
        new LatLng($place->lat, $place->lng),
        new LatLng($lat, $lng) // (lat; lng) from $params
      ))
    );

    // Check if the second city is almost as close to the spot, as the first city
    if ($city['distance'] - $closest_cities[0]['distance'] > $wgHwMapCityCloseDistance) {
      return true;
    }

    // Add second city to the result set
    $this->getResult()->addValue('cities', array(), $city);

    return true;
  }

  /**
   * Produce API error when geocoder API isn't available
   */
  public geocoderUnavailableAPIError() {
    global $wgVersion;

    $msg = 'Geocoder is currently unavailable. Try again later.';
    $code = 'geocoderUnavailable';

    $mwSupportsDieWithError = version_compare($wgVersion, '1.29', '>=');

    if ($mwSupportsDieWithError) {
      // MediaWiki 1.29 and newer
      // https://doc.wikimedia.org/mediawiki-core/master/php/classApiBase.html#a66ea5959af0a75c62c90be5dff929d6
      $this->dieWithError(
        $msg,
 	      $code,
 	      null, // data
 	      503 // http code 503 "service unavailable" (implies it's temporary)
      );
    } else {
      // MediaWiki 1.28 and older
      // `dieUsageMsg` is deprecated
      $this->dieUsageMsg(array($code, $msg));
    }
  }

  // API endpoint description
  public function getDescription() {
    return 'Get the most relevant nearby cities.';
  }

  // Parameters
  public function getAllowedParams() {
    return array(
      'lat' => array(
        ApiBase::PARAM_TYPE => 'string',
        ApiBase::PARAM_REQUIRED => true
      ),
      'lng' => array(
        ApiBase::PARAM_TYPE => 'string',
        ApiBase::PARAM_REQUIRED => true
      )
    );
  }

  // Describe the parameter
  public function getParamDescription() {
    return array_merge( parent::getParamDescription(), array(
      'lat' => 'Latitude of the point',
      'lng' => 'Longitude of the point'
    ) );
  }

  /**
   * Check if Geonames.org `$place` is a big city
   * @return Boolean
   */
  private function isBigCity($place) {
    global $wgHwMapBigCityMinPopulation;

    return (
      ($place->fcode && in_array($place->fcode, ['PPLC', 'PPLA'])) || // country capital (eg. Warsaw) or regional capital (eg. Lviv)
      ($place->population && $place->population >= $wgHwMapBigCityMinPopulation) // populated city (eg. Rotterdam)
    );
  }
}
