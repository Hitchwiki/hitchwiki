(function(mw, $) {

  mw.log('HWMaps::NewSpot');

  var newSpotMarker,
      $newSpotWrap,
      $newSpotForm,
      $newSpotInitButton,
      geocoderQuery;

  /**
   * @class mw.HWMaps.NewSpot
   *
   * @constructor
   */
  function NewSpot() {
    mw.log('HWMaps::NewSpot::constructor');
  }

  /**
   * Initiate UI for adding a new spot.
   * Tear down everything this function does by calling `clearAddNewSpotUI()`
   */
  NewSpot.setupNewSpot = function() {
    mw.log('HWMaps::NewSpot::setupNewSpot');

    $newSpotWrap = $('#hwmap-add-wrap');
    $newSpotForm = $newSpotWrap.find('form');
    $newSpotInitButton = $('#hwmap-add');

    // Place marker to the middle of the map
    var newMarkerLocation = mw.HWMaps.leafletMap.getCenter();

    // Hide "add new spot" button
    $newSpotInitButton.hide();

    $newSpotWrap.fadeIn('fast');

    // Attach event to "cancel" button
    $newSpotWrap.find('#hwmap-cancel-adding').click(function(e) {
      clearAddNewSpotUI();
    });

    // Cancel adding new spot by hitting esc key
    $(document).on('keydown.escape', function(e) {
      var keycode = ((typeof e.keyCode !== 'undefined' && e.keyCode) ? e.keyCode : e.which);
      if (keycode === 27) { // escape key maps to keycode `27`
        mw.log('HWMaps::NewSpot::setupNewSpot: keydown.excape');
        // Clear UI
        clearAddNewSpotUI();
        // Clear out this event listener
        $(document).off('keydown.escape');
      };
    });

    // Stop clicking map trough this this area
    $newSpotWrap.click(function(e) {
      e.stopPropagation();
    });

    // Craete new spot marker + layer
    newSpotMarker = L.marker(newMarkerLocation, {
      icon: mw.HWMaps.icons.new,
      draggable: true,
      title: 'Drag me!'
    });

    // Dragged location of the new spot
    // Preset some values at the form
    newSpotMarker.on('dragend', function(event) {
      newSpotReverseGeocode(event.target.getLatLng());
    });

    // Move marker to where user clicked on the map
    mw.HWMaps.leafletMap.on('click', setNewSpotMarkerLocation);

    // Create a separate Leaflet layer for "new place" marker
    mw.HWMaps.leafletLayers.newSpot = new L.layerGroup([newSpotMarker]).addTo(mw.HWMaps.leafletMap);

    // Since marker is at the beginning placed in the middle
    newSpotReverseGeocode(newMarkerLocation);

    /*
    // Modifying Mediawiki SemanticForms popup to please our needs
    $newSpotWrap.find('form.popupforminput').submit(function(evt) {
      var iframeTimer,
          needsRender,
          $popup = $('.popupform-innerdocument'); // There's also `.popupform-wrapper`

      // `.popupform-innerdocument` was removed from DOM because successfully
      // adding new spot, cancelling or any other reason.
      $popup.on('remove', function() {
        clearAddNewSpotUI();
      });

      // store initial readystate
      var readystate = $popup.contents()[0].readyState;

      // set up iframeTimer for waiting on the document in the iframe to be dom-ready
      // this sucks, but there is no other way to catch that event
      // onload is already too late
      //
      // This code is from SemanticForms PF_popupform.js
      // https://github.com/wikimedia/mediawiki-extensions-PageForms/blob/REL1_28/libs/PF_popupform.js
      iframeTimer = setInterval(function() {
        // if the readystate changed
        if (readystate !== $popup.contents()[0].readyState) {
          // store new readystate
          readystate = $popup.contents()[0].readyState;
          // if dom is built but document not yet displayed
          if (readystate === 'interactive') {
            needsRender = false; // flag that rendering is already done
            setupNewSpotFormContents(iframeTimer, $popup);
          }
        }
      }, 100 );
      // fallback in case we did not catch the dom-ready state
      $popup.on('load', function(event) {
        if (needsRender) { // rendering not already done?
          setupNewSpotFormContents(iframeTimer, $popup);
        }
        needsRender = true;
      });
    });
    */

  };

  /**
   * After popup and iframe inside it has loaded,
   * tweak some contents to suit us better.
   */
  function setupNewSpotFormContents(iframeTimer, $popup) {
    mw.log('HWMaps::NewSpot::setupNewSpotFormContents');
    clearTimeout(iframeTimer);

    // Modify contents of that popup
    $popup
      .contents()

      // No title at this form
      .find('#firstHeading').hide().end()

      // For some odd reason, these Select2 inputs have fixed min-style:600px
      // That sucks. This removes them, and they're handled at
      // HitchwikiVector/resources/styles/forms.less instead.
      //
      // Removed: doesn't function right now — occurs perhaps before `select2()` ?
      // .find('.select2-container').attr('style', '').end()

      .contents();
  }

  /**
   * Clean out adding new spot UI elements and event listeners
   */
  function clearAddNewSpotUI() {
    mw.log('HWMaps::NewSpot::clearAddNewSpotUI');

    // Hide UI buttons
    $newSpotWrap.fadeOut('fast');
    $newSpotInitButton.fadeIn('fast');

    // Clear UI button references
    $newSpotWrap = null;
    $newSpotForm = null;
    $newSpotInitButton = null;

    // Remove Leaflet layer
    if (mw.HWMaps.leafletMap.hasLayer(mw.HWMaps.leafletLayers.newSpot)) {
      mw.HWMaps.leafletMap.removeLayer(mw.HWMaps.leafletLayers.newSpot);
    }

    // Remove event listener
    mw.HWMaps.leafletMap.off('click', setNewSpotMarkerLocation);

    // Clear out the marker object
    newSpotMarker = null;

    // Clear out layer where that marker was placed
    mw.HWMaps.leafletLayers.newSpot = null;

    // Clear any on-going geocoder queries
    if (geocoderQuery) {
      geocoderQuery.abort();
    }
  }

  /**
   * Sets marker to a clicked spot on map
   */
  function setNewSpotMarkerLocation(event) {
    mw.log('HWMaps::NewSpot::setNewSpotMarkerLocation');
    mw.log(event);
    if (!event || !event.latlng) {
      mw.log.error('HWMaps::NewSpot::setNewSpotMarkerLocation: No click event! #fsadjk');
      return;
    }
    // Move marker to new location
    newSpotMarker.setLatLng(event.latlng);

    // Geocode new location
    newSpotReverseGeocode(event.latlng);
  }

  /**
   * Reverse geocode (lat,lon => place name)
   * @todo refactor, it's quite messy...
   * @param latLng Leaflet latLng object (http://leafletjs.com/reference-1.0.0.html#latlng)
   */
  function newSpotReverseGeocode(latLng) {
    mw.log('HWMaps::NewSpot::newSpotReverseGeocode');

    // No coordinates?
    if (!latLng) {
      mw.log.error('HWMaps::NewSpot::newSpotReverseGeocode: no coordinates #j9387u');
      return;
    }

    // Abort any previous geocoding instances
    // Prevents multiple geocoders finishing up when user moves the marker fast
    mw.log('geocoderQuery:');
    mw.log(geocoderQuery);
    if (geocoderQuery) {
      mw.log('HWMaps::NewSpot::newSpotReverseGeocode: clear out previous geocoding query #g93hgf');
      geocoderQuery.abort();
    }

    var city = '',
        country = '',
        isBigCity = false,
        // Get this value from config, but default to 500K
        // Defined at `HWMap.php`
        geocoderMinPopulationNonCapital = mw.config.get('wgHwMapBigCityMinPopulation', 500000);

    // Cache jQuery elements
    var $inputCity = $newSpotForm.find('input[name="Spot[Cities]"]'),
        $inputCountry = $newSpotForm.find('input[name="Spot[Country]"]'),
        $inputLocation = $newSpotForm.find('input[name="Spot[Location]"]'),
        $submitButton = $newSpotForm.find('input[type="submit"]'),
        submitButtonValContinue = mw.message('hwmap-continue').text(),
        submitButtonValWait = mw.message('hwmap-wait').text();

    // Empty previously set input values
    $inputCity.val('');
    $inputCountry.val('');

    function fillSpotForm() {
      mw.log('HWMaps::NewSpot::newSpotReverseGeocode.fillSpotForm');

      // Prefill city input at the form
      if (city !== '') {
        //placeName += city;
        if (isBigCity) {
          $inputCity.val(city);
        }
      }

      // Prefill country input at the form
      if (country !== '') {
        $inputCountry.val(country);
      }

      // Enable the form again
      $submitButton.prop('disabled', false);
      $submitButton.val(submitButtonValContinue);
    }

    // Disable submit button
    $submitButton.prop('disabled', true);
    $submitButton.val(submitButtonValWait);

    // Spot coordinates
    $inputLocation.val(latLng.lat + ',' + latLng.lng);

    // See GeoPoint `ext.HWMap.GeoPoint.js` for `GeoPoint` class
    var point = new mw.HWMaps.GeoPoint(latLng.lat, latLng.lng);
    var bbox = point.boundingCoordinates(20, null, true),
        queryingGeocoder;

    var geocoderQuery = $.getJSON(mw.util.wikiScript('api'), {
      action: 'hwgeocoder',
      format: 'json',
      // `latitude()` and `longitude()` are `mw.HWMaps.GeoPoint` methods
      NElat: bbox[1].latitude(), // north
      NElon: bbox[1].longitude(), // east
      SWlat: bbox[0].latitude(), // south
      SWlon: bbox[0].longitude(), // west
      style: 'FULL',
      maxRows: 1,
      geocodingService: 'cities',
      // lang: 'en', // Gets set by default at the backend to `en`
    }).done(function(data) {

      geocoderQuery = null;

      mw.log('HWMaps::NewSpot::newSpotReverseGeocode: got hwgeocoderapi cities response');
      mw.log(data);

      if (data.error) {
        mw.log.warn('HWMaps::NewSpot::newSpotReverseGeocode: Geocoder returned an error');
        mw.log.warn(data.error);
      }

      if (data.query && _.isArray(data.query) && data.query.length > 0) {
        place = data.query[0];

        mw.log(place);

        isBigCity = (
          (place.fcode && $.inArray(place.fcode, ['PPLC', 'PPLA']) !== -1) || // country capital (eg. Warsaw) or regional capital (eg. Lviv)
          (place.population && place.population >= geocoderMinPopulationNonCapital) // populated city (eg. Rotterdam)
        );

        city = place.name ? place.name : '';
        country = place.countryName ? place.countryName : '';

        if (!place.countryName && place.countrycode) {
          var geocoderQuery = $.getJSON(mw.util.wikiScript('api'), {
            action: 'hwgeocoder',
            format: 'json',
            country: place.countrycode,
            style: 'FULL',
            maxRows: 1,
            geocodingService: 'countryInfo',
            // lang: 'en', // Gets set by default at the backend to `en`
          }).done(function(data) {

            mw.log('HWMaps::NewSpot::newSpotReverseGeocode: got hwgeocoderapi countryInfo response');
            mw.log(data);

            geocoderQuery = null;

            if (_.isArray(data.query) && data.query.length > 0) {
              var countryInfo = data.query[0];
              if (countryInfo && countryInfo.countryName) {
                country = countryInfo.countryName;
              }
            }

            fillSpotForm();
          })
          .fail(function() {
            // country info lookup request failed
            fillSpotForm();
          });
        } else { // no country code in city search response
          fillSpotForm();
        }

      } else { // no closeby cities found
        fillSpotForm();
      }
    })
    .fail(function() {
      // city search request failed
      fillSpotForm();
    });
  }

  // Export class
  mw.HWMaps.NewSpot = NewSpot;

}(mediaWiki, jQuery));
