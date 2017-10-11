<?php

/**
 * Geocoding Cities API is a wrapper for Geonames's API
 * which currently doesn't support https on free tier.
 *
 * This also make it easier to change geocoding provider
 * to something new and not needing to restructure client code.
 *
 * geocodingService `cities`:
 * Returns a list of cities and placenames in the bounding box, ordered by
 * relevancy (capital/population). Placenames close together are filterered
 * out and only the larger name is included in the resulting list.
 *
 * geocodingService `countryInfo`:
 * Country information : Capital, Population, Area in square km,
 * Bounding Box of mainland (excluding offshore islands)
 *
 * Example how to query `countryInfo` from MediaWiki JavaScript:
 * ```
 * $.getJSON(mw.util.wikiScript('api'), {
 *   action: 'hwgeocoder',
 *   format: 'json',
 *   country: 'FI',
 *   style: 'FULL',
 *   maxRows: 1,
 *   geocodingService: 'countryInfo',
 *   // lang: 'en' // Gets set by default at the backend to `en`
 * }).done(function(country) { console.log(country); });
 * ```
 *
 * http://www.geonames.org/export/JSON-webservices.html
 * http://www.geonames.org/export/web-services.html
 */
class HWGeocoderApi extends ApiBase {

  public function execute() {
    global $hwGeonamesUsername;

    // If Geonames username isn't set, return error
    if (empty($hwGeonamesUsername)) {
      $this->geocoderUnavailableAPIError();
      return true;
    }

    // Get parameters
    $params = $this->extractRequestParams();

    // Response style
    $geonames_style = (string) $params['style'];

    // Max rows
    $geonames_maxRows = (int) $params['maxRows'];

    // Language (default: `en`)
    $geonames_lang = (string) $params['lang'];

    // Query parameters to be sent to GeoNames API
    $query_params = array(
      'style' => $geonames_style,
      'lang' => $geonames_lang,
      'maxRows' => $geonames_maxRows,
      'username' => $hwGeonamesUsername
    );

    /**
     * Bounding box
     *  -------------NE
     * |              |
     * |              |
     * |              |
     * |              |
     * |              |
     * SW-------------
     */
    if ($params['geocodingService'] === 'cities') {

      // Yeld error when missing one of parameters
      if (!isset($params['NElat']) ||
          !isset($params['NElon']) ||
          !isset($params['SWlat']) ||
          !isset($params['SWlon'])) {
        $this->geocoderAPIError(
          'Missing one of the required parameters: NElat, NElon, SWlat or SWlon.', // error msg
          'missingparam', // error code
          array(
            '*' => 'See http://www.geonames.org/export/JSON-webservices.html for detailed API usage.'
          ), // data
          200 // http status code
        );
        return true;
      }

      // Add these to query parameters
      $query_params = array_merge($query_params, array(
        'north' => (double) $params['NElat'],
        'east' => (double) $params['NElon'],
        'south' => (double) $params['SWlat'],
        'west' => (double) $params['SWlon'],
      ));
    }

    // Add `country` to query parameters
    // If `country` isn't available, API will return all countries
    if ($params['geocodingService'] === 'countryInfo' && isset($params['country'])) {
      $query_params = array_merge($query_params, array(
        'country' => (string) $params['country']
      ));
    }

    // Call Geonames API
    $response = Http::get(
      'http://api.geonames.org/' .
      $params['geocodingService'] .
      'JSON?' .
      http_build_query($query_params)
    );

    if ($response === false) {
      // Api error:
      $this->geocoderUnavailableAPIError();
    } else {
      // Api result:
      $response = json_decode($response);
      if ($response && isset($response->geonames)) {
		    $this->getResult()->addValue(null, 'query', $response->geonames);
      } else {
        // Api error:
        $this->geocoderAPIError(
          'Geocoder did not find any results for this query.', // error msg
          'geocoderNoResult', // error code
          null, // data
          204 // http status code 204 "no content"
        );
      }
    }

    return true;
  }

  /**
   * Produce API error when geocoder API isn't available
   */
  public function geocoderUnavailableAPIError() {
    $this->geocoderAPIError(
      'Geocoder is currently unavailable. Try again later.', // error msg
      'missingparam', // error code
      array(
        '*' => 'See http://www.geonames.org/export/JSON-webservices.html and ' .
               'http://www.geonames.org/export/web-services.html for API usage.'
      ), // data
      503 // http status code 503 "service unavailable" (implies it's temporary)
    );
  }

  /**
   * Produce API error
   * `dieUsage` is deprecated.
   * This ensures errors will work even if nobody updates this code in future.
   */
  public function geocoderAPIError($msg = null, $code = null, $data = null, $httpCode = null) {
    global $wgVersion;

    $supportsDieWithError = version_compare($wgVersion, '1.29', '>=');

    if ($supportsDieWithError) {
      // MediaWiki 1.29 and newer
      // https://doc.wikimedia.org/mediawiki-core/master/php/classApiBase.html#a66ea5959af0a75c62c90be5dff929d6
      $this->dieWithError(
        $msg,
 	      $code,
 	      $data,
 	      $httpCode
      );
    } else {

      // MediaWiki 1.28 and older
      if ($httpCode === null) {
        $httpCode = 0;
      }

      // https://doc.wikimedia.org/mediawiki-core/1.28.0/php/classApiBase.html#a3bbd2e864a2dec0dd468f6e35db8cb8a
      $this->dieUsage(
        $msg,
 	      $code,
 	      $httpCode,
 	      $data
      );
    }
  }

  // API endpoint description
  public function getDescription() {
    return 'Offers two kinds of geocoding services: ' .
           '\n\n' .
           'Service "cities":\n' .
           'Returns a list of cities and placenames in the bounding box, ' .
           'ordered by relevancy (capital/population). Placenames close ' .
           'together are filterered out and only the larger name is included ' .
           'in the resulting list. \n' .
           'Result format follows pattern of Geonames ' .
           '"Cities and Placenames" API: \n' .
           'http://www.geonames.org/export/JSON-webservices.html' .
           '\n\n' .
           'Service "countryInfo":' .
           'Country information : Capital, Population, Area in square km, ' .
           'Bounding Box of mainland (excluding offshore islands). \n' .
           'Result format follows pattern of Geonames ' .
           '"Country Info" API: \n' .
           'http://www.geonames.org/export/web-services.html';
  }

  // Parameters
  public function getAllowedParams() {
    return array(
      'NElat' => array(
        ApiBase::PARAM_TYPE => 'string'
      ),
      'NElon' => array(
        ApiBase::PARAM_TYPE => 'string'
      ),
      'SWlat' => array(
        ApiBase::PARAM_TYPE => 'string'
      ),
      'SWlon' => array(
        ApiBase::PARAM_TYPE => 'string'
      ),
      'maxRows' => array(
        ApiBase::PARAM_TYPE => 'integer',
        ApiBase::PARAM_DFLT => 10
      ),
      'lang' => array(
        ApiBase::PARAM_TYPE => 'string',
        ApiBase::PARAM_DFLT => 'en'
      ),
      'country' => array(
        ApiBase::PARAM_TYPE => 'string'
        //ApiBase::PARAM_ISMULTI => true // Geonames would support multiple `country` params
      ),
      'style' => array(
        ApiBase::PARAM_TYPE => 'string',
        ApiBase::PARAM_DFLT => 'MEDIUM',
        // Allowed values:
        ApiBase::PARAM_TYPE => array('SHORT', 'MEDIUM', 'LONG', 'FULL')
      ),
      'geocodingService' => array(
        ApiBase::PARAM_TYPE => 'string',
        ApiBase::PARAM_REQUIRED => true,
        // Allowed values:
        ApiBase::PARAM_TYPE => array('cities', 'countryInfo')
      )
    );
  }

  // Describe parameters
  public function getParamDescription() {
    return array_merge(
      parent::getParamDescription(),
      array(
        'NElat' => 'North East latitude of the bounding box',
        'NElon' => 'North East longitude of the bounding box',
        'SWlat' => 'South West latitude of the bounding box',
        'SWlon' => 'South West longitude of the bounding box',
        'maxRows' => 'Maximal number of rows returned (default = 10)',
        'country' => 'ISO-3166 country code. Default is all countries.',
        'geocodingService' => 'Geocoder service to use. Available: `cities` and `countryInfo`.',
        'lang' => 'ISO-639-1 language code. Language of placenames and wikipedia urls (default = en)',
        'style' => 'Verbosity of returned document, default = MEDIUM, possible values = SHORT,MEDIUM,LONG,FULL',
      )
    );
  }

}
