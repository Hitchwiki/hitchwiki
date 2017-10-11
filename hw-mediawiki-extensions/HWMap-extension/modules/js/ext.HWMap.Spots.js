/**
 * Functions used for operations on spots
 */

(function(mw, $, L, Ractive) {
  mw.log('mw.HWMaps::Spots');

  /**
   * @class mw.HWMaps.Spots
   *
   * @constructor
   */
  function Spots() {
    mw.log('HWMaps::Spots::constructor');
  }

  /**
   * Leaflet-icon builder for spot markers
   *
   * @param {number} rating
   * @return L.marker
   */
  Spots.getSpotIcon = function(rating) {
    mw.log('HWMaps::Spots::getSpotIcon');

    // Validate rating
    rating = Number(rating || 0);

    if (rating >= 4.5) {
      return mw.HWMaps.icons.verygood;
    }
    else if (rating >= 3.5) {
      return mw.HWMaps.icons.good;
    }
    else if (rating >= 2.5 ) {
      return mw.HWMaps.icons.average;
    }
    else if (rating >= 1.5) {
      return mw.HWMaps.icons.bad;
    }
    else if (rating >= 1) {
      return mw.HWMaps.icons.senseless;
    }

    return mw.HWMaps.icons.unknown;
  };

  /**
   * Clear markers from the map
   */
  Spots.clearMarkers = function(category) {
    mw.log('HWMaps::Spots::clearMarkers');
    if (!category || category === 'Spots') {
      mw.HWMaps.leafletLayers.spots.RemoveMarkers();
    }
    if (!category || category === 'Cities') {
      mw.HWMaps.leafletLayers.cities.RemoveMarkers();
    }
  };

  /**
   * Populate map with city or spot markers
   * @param {string} category, `Cities` or `Spots`
   */
  Spots.getMarkers = function(category, zoom) {
    mw.log('HWMaps::Spots::getMarkers');

    // Validate category && zoom
    category = String(category || '');
    zoom = parseInt(zoom, 10) || 0; // `parseInt` could return `NaN`

    // Get current bounding box from the map
    bounds = mw.HWMaps.leafletMap.getBounds();

    // Check if current bouding box is different
    // than previously saved bounding box
    if (bounds._northEast.lat > mw.HWMaps.lastBounds.NElat ||
       bounds._northEast.lng > mw.HWMaps.lastBounds.NElng ||
       bounds._southWest.lat < mw.HWMaps.lastBounds.SWlat ||
       bounds._southWest.lng < mw.HWMaps.lastBounds.SWlng ||
       zoom !== mw.HWMaps.lastZoom) {
      mw.log('HWMaps::Spots::getMarkers: Out of cached bounds, get fresh markers!');

      // mw.HWMaps.Map.clearMarkers();

      // Extends cached bounds so that we'll allow little bit of movement
      // without fetching new set of spots
      mw.HWMaps.lastBounds = {
        NElat: bounds._northEast.lat + 1,
        NElng: bounds._northEast.lng + 1,
        SWlat: bounds._southWest.lat - 1,
        SWlng: bounds._southWest.lng - 1
      };
    } else {
      mw.log('HWMaps::Spots::getMarkers: Inside previously cached bounds.');
      return;
    }

    // Build the API URL
    var queryUri = new mw.Uri(mw.util.wikiScript('api'));
    queryUri.extend({
      action: 'hwmap',
      category: category,
      SWlat: mw.HWMaps.lastBounds.SWlat,
      SWlon: mw.HWMaps.lastBounds.SWlng,
      NElat: mw.HWMaps.lastBounds.NElat,
      NElon: mw.HWMaps.lastBounds.NElng,
      format: 'json'
    });

    mw.log('HWMaps::Spots::getMarkers: API Query:');
    mw.log(queryUri.toString());

    // Query API
    $.get(queryUri.toString(), function(data) {

      mw.log('HWMaps::Spots::getMarkers: API response:');
      mw.log(data);

      // API returned error
      if (data.error) {
        // Bubble notification
        // `mw.message` gets message translation, see `i18n/en.json`
        // `tag` replaces any previous bubbles by same tag
        // https://www.mediawiki.org/wiki/ResourceLoader/Modules#mediawiki.notify
        mw.notify(
          mw.message('hwmap-error-loading-markers').text() + ' ' + mw.message('hwmap-please-reload').text(),
          { tag: 'hwmap-error' }
        );
        // Console log
        mw.log.error('HWMaps::Spots::initialize error getting data from the API #348fhj');
        mw.log.error(data.error);
        return;
      }

      // Clear out possibly previous markers from the map
      mw.HWMaps.Map.clearMarkers(category);

      // No data from the API
      if (!data.query) {
        mw.log('HWMaps::Spots::initialize API did not return any points. #g31128');
        return;
      }

      // Add the new markers
      var spots = data.query.spots;
      for (var i = -1, len = spots.length; ++i < len;) {

        // Build a marker
        var marker = new PruneCluster.Marker(
          spots[i].location[0],
          spots[i].location[1]
        );

        // Attach article ID to marker
        marker.data.HWid = spots[i].id;

        if (spots[i].category === 'Spots') {
          // Add icon
          marker.data.icon = Spots.getSpotIcon(spots[i].average_rating);
          marker.data.HWtype = 'spot';

          // Register marker
          mw.HWMaps.leafletLayers.spots.RegisterMarker(marker);
        }
        else if (spots[i].category === 'Cities') {
          // Add icon
          marker.data.icon = mw.HWMaps.icons.city;
          marker.data.title = spots[i].title;
          marker.data.HWtype = 'city';

          // Register marker
          mw.HWMaps.leafletLayers.cities.RegisterMarker(marker);
        }
      }

      // Change cluster area size depending on the zoom level
      // Higher number means more markers "merged".
      // https://github.com/SINTEF-9012/PruneCluster#set-the-clustering-size
      if (zoom !== mw.HWMaps.lastZoom) {
        mw.HWMaps.lastZoom = zoom;
        if (zoom < 8) {
          mw.HWMaps.leafletLayers.spots.Cluster.Size = 120;
        }
        else if (zoom < 11) {
          mw.HWMaps.leafletLayers.spots.Cluster.Size = 80;
        }
        else {
          mw.HWMaps.leafletLayers.spots.Cluster.Size = 10;
        }
      }

      // Ensure PruneCluster notices new markers
      if (!category || category === 'Spots') {
        mw.HWMaps.leafletLayers.spots.ProcessView();
      }
      if (!category || category === 'Cities') {
        mw.HWMaps.leafletLayers.cities.ProcessView();
      }

      // Tooltips for city markers
      // `jQuery.tipsy` got deprecated in MW 1.28 and should
      // thus be replaced with something else, e.g. OOjs UI:
      // https://www.mediawiki.org/wiki/OOjs_UI
      if (typeof $.fn.tipsy === 'function') {
        $('.tipsy').remove();
        $('.hw-city-icon').tipsy({
          title: function() {
            var orginalTitle = this.getAttribute('original-title');
            return orginalTitle ? mw.message('hwmap-open-cityname', orginalTitle.replace(/_/g, ' ')).text() : mw.message('hwmap-open-city').text();
          },
          gravity: $.fn.tipsy.autoNS || false
        });
      } else {
        mw.log.warn('HWMaps::Spots: No jQuery Tipsy available. #fj93jh');
      }

    });

  };

  /**
   * Get string presentation of a numeric hitchability rating
   * @param {int} rating 0-5
   * @return {string}
   */
  Spots.getRatingLabel = function(rating) {
    mw.log('HWMaps::Spots::getRatingLabel');

    // Validate rating
    rating = Number(rating || 0);

    // See https://www.mediawiki.org/wiki/Manual:Messages_API
    // for details how to use `mw.message()`
    if (rating >= 4.5) {
      return mw.message('hwmap-hitchability-very-good').text();
    }

    if (rating >= 3.5) {
      return mw.message('hwmap-hitchability-good').text();
    }

    if (rating >= 2.5 ) {
      return mw.message('hwmap-hitchability-average').text();
    }

    if (rating >= 1.5) {
      return mw.message('hwmap-hitchability-bad').text();
    }

    if (rating >= 1) {
      return mw.message('hwmap-hitchability-senseless').text();
    }

    return mw.message('hwmap-hitchability-unknown').text();
  };

  /**
   * parse timestamp into a human readable format
   * @todo Use Moment.js here instead, it ships with MediaWiki.
   * @param {string} timestamp
   * @return {string}
   */
  Spots.parseTimestamp = function(timestamp) {
    mw.log('HWMaps::Spots::parseTimestamp: ' + timestamp);
    return timestamp ? timestamp.slice(6, 8) + '.' + timestamp.slice(4, 6) + '.' + timestamp.slice(0, 4) : '';
  };

  /**
   * Open Google Street View at coordinates
   *
   * @param {Float} lat
   * @param {Float} lng
   */
  Spots.openStreetView = function(lat, lng) {
    mw.log('HWMaps::Spots::openStreetView: ' + parseFloat(lat) + ', ' + parseFloat(lng));
    window.open('https://maps.google.com/maps?q=&layer=c&cbll=' + parseFloat(lat) + ',' + parseFloat(lng), '_blank');
  };

  /**
   * Redraw icon for marker by id when its rating changes
   */
  Spots.updateSpotMarker = function(id, newRating) {
    for (var i = 0; i < mw.HWMaps.leafletLayers.spots.Cluster._markers.length; i++) {
      if (mw.HWMaps.leafletLayers.spots.Cluster._markers[i].data.HWid === id) {
        if (mw.HWMaps.leafletLayers.spots.Cluster._markers[i].data.average !== newRating) {
          mw.HWMaps.leafletLayers.spots.Cluster._markers[i].data.icon = Spots.getSpotIcon(newRating);
          mw.HWMaps.leafletLayers.spots.Cluster._markers[i].data.average = newRating;
          mw.HWMaps.leafletLayers.spots.RedrawIcons();
          mw.HWMaps.leafletLayers.spots.ProcessView();
        }
        break;
      }
    }
  };


  /**
   * Load statistics for "waiting times" and "ratings"
   *
   * @param {Integer}  pageId  MediaWiki page id of the spot.
   * @param {String}   loadingWrapperId ID of the element where loading animation will be appended (set false to disable)
   * @param {String}   spotObjectPath   RactiveJS object path
   */
  Spots.loadStatistics = function(pageId, loadingWrapperId, spotObjectPath) {
    mw.log('mw.HWMaps::City::loadSpotDetails: ' + pageId);

    if (loadingWrapperId) {
      // Animated loading spinner
      // https://doc.wikimedia.org/mediawiki-core/master/js/#!/api/jQuery.plugin.spinner
      var $loadSpotDetailsSpinner = $.createSpinner({
        // ID used to refer this spinner when removing it
        id: 'hwLoadSpotDetailsSpinner',

        // Size: 'small' or 'large' for a 20-pixel or 32-pixel spinner.
        size: 'small',

        // Type: 'inline' or 'block'.
        // Inline creates an inline-block with width and height
        // equal to spinner size. Block is a block-level element
        // with width 100%, height equal to spinner size.
        type: 'inline'
      });

      var $loadingWrapper = $('#' + loadingWrapperId);

      if ($loadingWrapper.length) {
        // Insert below where the spots are going to be loaded
        $loadingWrapper.append($loadSpotDetailsSpinner);
      }
    }

    var waitingTimesPromise = mw.HWMaps.Waitingtimes.loadWaitingTimes(pageId);
    var ratingsPromise = mw.HWMaps.Ratings.loadRatings(pageId);

    $.when(waitingTimesPromise, ratingsPromise).done(function(waitingTimeData, ratingsData) {
      mw.log('mw.HWMaps::City::loadSpotDetails: done');
      mw.log(waitingTimeData);
      mw.log(ratingsData);

      if (loadingWrapperId && $loadingWrapper.length) {
        $.removeSpinner('hwLoadSpotDetailsSpinner');
      }

      // Waiting times
      if (_.has(waitingTimeData, 'waiting_times')) {
        mw.HWMaps.ractive.set(spotObjectPath + '.waiting_times', waitingTimeData.waiting_times);
      }

      // Waiting times stats
      if (_.has(waitingTimeData, 'distribution')) {
        mw.HWMaps.ractive.set(spotObjectPath + '.waiting_times_distribution', waitingTimeData.distribution);
      }

      // Ratings
      if (_.has(ratingsData, 'ratings')) {
        mw.HWMaps.ractive.set(spotObjectPath + '.ratings', ratingsData.ratings);
      }

      // Ratings stats
      if (_.has(ratingsData, 'distribution')) {
        mw.HWMaps.ractive.set(spotObjectPath + '.ratings_distribution', ratingsData.distribution);
      }

      // Show stats html
      // http://docs.ractivejs.org/latest/ractive-toggle
      mw.HWMaps.ractive.set(spotObjectPath + '._isStatisticsVisible', true);
    })
    .fail(function() {
      mw.log.error('mw.HWMaps::City::loadSpotDetails: failed');
      if ($loadingWrapper.length) {
        $.removeSpinner('hwLoadSpotDetailsSpinner');
      }
    });

  };


  // Export
  mw.HWMaps.Spots = Spots;

}(mediaWiki, jQuery, L, Ractive));
