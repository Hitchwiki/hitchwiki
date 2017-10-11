/**
 * Country articles
 */

(function(mw, $, L) {
  mw.log('mw.HWMaps::Country');

  /**
   * @class mw.HWMaps.Country
   *
   * @constructor
   */
  function Country() {
    mw.log('mw.HWMaps::Country::constructor');
  }

  Country.initialize = function() {
    mw.log('HWMaps::Country::initialize');

    // Getting the coordinates for current article
    mw.HWMaps.Map.getArticleCoordinates().then(function(articleCoordinates) {
      if (articleCoordinates) {
        // Center map to coordinates stored to article
        // (coordinates, zoomlevel)
        mw.HWMaps.leafletMap.setView(articleCoordinates, 5);
      } else {
        // Couldn't get coordinates, just zoom out to the whole world
        mw.HWMaps.leafletMap.fitWorld();
        mw.log.warn('HWMaps::Country::initialize: could not find article coordinates. #j3jkkf');
      }

      mw.HWMaps.leafletLayers.cities.PrepareLeafletMarker = prepareViewMarkers;
      mw.HWMaps.leafletMap.on('moveend', onCountryMapMoveEnd);

      // Firing this event to initialize getting spots in bounding box
      // See the event hook above and `onCountryMapMoveEnd()` for more.
      mw.HWMaps.leafletMap.fireEvent('moveend');

    });
  };

  /**
   * Fire event when Leaflet map moves
   */
  function onCountryMapMoveEnd() {
    mw.log('HWMaps::Country::onCountryMapMoveEnd');

    // mw.log(mw.HWMaps.leafletLayers.spots._topClusterLevel._childcount);
    // Get spots when zoom is bigger than 4
    var zoom = mw.HWMaps.leafletMap.getZoom();

    if (zoom > 4) {
      mw.HWMaps.Spots.getMarkers('Cities', zoom);
    }
    // When zoom is smaller than 4 we clear the markers if not already cleared
    else {
      mw.HWMaps.Spots.clearMarkers();
      mw.HWMaps.Map.resetMapState();
    }
  }

  /**
   * This constructs city icons for the countrymap
   * Attaches an event which brings user to city article when clicking a marker
   */
  function prepareViewMarkers(leafletMarker, data) {
    leafletMarker.setIcon(data.icon, data.HWid, data.title);
    leafletMarker.on('click', function() {
      window.location = wgArticlePath.replace('$1', data.title);
    });
  }

  // Export
  mw.HWMaps.Country = Country;

}(mediaWiki, jQuery, L));
