/**
 * Hitchwiki Location Field
 * Relies to Leaflet.js
 */

(function ($, mw) {
  'use strict';

  mw.log('HWLocationInput');

  // Default location for the empty input
  // defaults to Europe `[(float) lat, (float) lng]`
  var defaultCenter = mw.config.get('hwLocationInputDefaultCenter', [48.6908333333, 9.14055555556]);

  // Defaults to zoomlevel 5 if not set (quite high from the ground)
  var defaultZoom = mw.config.get('hwLocationInputDefaultZoom', 5);

  // Input field where location is stored will be attached to this
  var inputElement;

  // Mapbox settings coming from MediaWiki Config file
  var mapboxUsername = mw.config.get('hwLocationInputMapboxUsername', false),
      mapboxAccessToken = mw.config.get('hwLocationInputMapboxAccessToken', false),
      mapboxMapkeyStreets = mw.config.get('hwLocationInputMapboxMapkeyStreets', false);

  // Path for extension images
  var extensionImagesFolder = mw.config.get('wgExtensionAssetsPath') + '/HWLocationInput/modules/img/';

  // Initialize UI
  initHWLocationInput();


  /**
   * Initialize UI
   */
  function initHWLocationInput() {

    // Loop trough each `<div>` for maps.
    // Usually there is only one of these, but if we had multiple
    // `HW_Location` fields, we'd have multiple of these, too.
    $('.hw_location_map').each(function() {

      var fieldNumber = $(this).data('field-number'),
          // id of the `<div>` element where the map will be
          mapId = 'hw_location_map_' + fieldNumber,
          // id of the `<input>` field where coordinate value is stored
          inputId = 'hw_location_input_' + fieldNumber;

      // Coordinates get replaced by input value if input field isn't empty
      // Otherwise Leaflet map gets build by default coordinates
      var coordinates = defaultCenter;

      // Zoom is set at the `<div>` where the map will be
      var zoom = parseInt($(this).data('zoom')) || defaultZoom;

      // Find input with values
      inputElement = $('#' + inputId);

      // See if input exists and has non-empty value
      if (inputElement.length && inputElement.val()) {

        // Split coordinates (e.g. `23.324, -21.123`)
        var coordinateValues = inputElement.val().split(',');

        // Something's wrong if we didn't get two values
        //
        if (coordinateValues.length !== 2) {
          mw.log.error('HWLocationInput: Invalid coordinates (' + coordinateValues.toString() + ') #ji32fw');
          return;
        }

        // Ensure our values are Float
        var lat = parseFloat(coordinateValues[0]);
        var lng = parseFloat(coordinateValues[1]);

        // Validate coordinates
        // With latitude and longitude, the values are bounded by ±90° and ±180° respectively.
        //if (lat > 90 || lat < 90 || lon > 180 || lon < 180) {
        //  mw.log.error('HWLocationInput: Invalid latitude or longitude (' + coordinateValues.toString() + ') #fau3kk');
        //  return;
        //}

        // Use input coordinates instead of previously set default map location
        coordinates = [lat, lng];
      }

      // Construct the map with the data we have
      constructMap(
        mapId,
        zoom,
        coordinates
      );
    });
  }


  /**
   * Construct the map
   *
   * @param mapId String Value of the `id` attribute of the `<div>` where
   *   Leaflet map should be constructed to
   * @param zoom Int Zoom level where map should be initialized
   * @param coordinates Array Coordinates where map should be centered when
   *   initialized and where the location marker should be placed to.
   */
  function constructMap(mapId, zoom, coordinates) {
    mw.log('HWLocationInput::initializeHWLocationInput: ' + mapId);

    if (!mapId || !zoom || !coordinates) {
      mw.log.error('HWLocationInput::initializeHWLocationInput: no mapId, zoom or coordinates defined. #UFak22');
      return;
    }

    // Array containing possibly multiple map objects
    var maps = [];

    // Create the Leaflet map
    maps[mapId] = L.map(mapId, {
      center: coordinates,
      zoom: zoom,
      attributionControl: false
    });

    // Fixes map loading partially, probably some sort of a CSS issue but this fixes it...
    // Feel free to fix if you have spare time. ;-)
    maps[mapId].whenReady(function() {
      setTimeout(function() { maps[mapId].invalidateSize(); }, 1000);
    });

    // These will be filled either by MapBox or OSM tile layer details
    var layerOptions,
        tilesUrl;

    if (mapboxUsername && mapboxAccessToken && mapboxMapkeyStreets) {
      // Using Mapbox tiles
      tilesUrl = 'https://{s}.tiles.mapbox.com/v4/{user}.{map}/{z}/{x}/{y}.png' + L.Util.getParamString({
        secure: 1, // 1=true | 0=false
        access_token: mapboxAccessToken
      });

      layerOptions = {
        attribution: '© <a href="https://www.openstreetmap.org/">OSM</a>. <strong><a href="https://www.mapbox.com/map-feedback/#' + mapboxUsername + '.' + mapboxMapkeyStreets + '/' + coordinates[1] + '/' + coordinates[0] + '/' + zoom + '">Improve this map</a></strong>',
        user: mapboxUsername,
        map: mapboxMapkeyStreets
      };
    } else {
      // If no MapBox available, fall back to OSM
      tilesUrl = 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png';

      layerOptions = {
        subdomains: ['a', 'b', 'c'],
        attribution: '© <a href="https://www.openstreetmap.org/" target="_blank">OSM</a> &amp; <a href="https://www.mapbox.com/" target="_blank">MapBox</a>. <strong><a href="https://www.openstreetmap.org/login#map=' + zoom + '/' + coordinates[0] + '/' + coordinates[1] + '">Improve this map</a></strong>'
      };
    }

    // Default settings for all layers (both OSM and MapBox)
    // http://leafletjs.com/reference-1.0.2.html#util-extend
    layerOptions = L.extend(layerOptions, {
      maxZoom: 18,
      continuousWorld: true
    });

    // Add Leaflet tile layer to the map
    // http://leafletjs.com/reference.html#tilelayer
    L.tileLayer(
      tilesUrl,
      layerOptions
    ).addTo(maps[mapId]);

    // Icon for the marker
    var markerIcon = L.icon({
      iconUrl:       extensionImagesFolder + 'marker.png',
      iconRetinaUrl: extensionImagesFolder + 'marker@2x.png',
      shadowUrl:     extensionImagesFolder + 'marker-shadow.png',
      iconSize:      [25, 35], // size of the icon
      shadowSize:    [33, 33], // size of the shadow
      iconAnchor:    [12, 35], // point of the icon which will correspond to marker's location
      shadowAnchor:  [5, 34],  // the same for the shadow
      popupAnchor:   [-3, -17] // point from which the popup should open relative to the iconAnchor
    });

    // Marker placed to coordinates found from the input field
    var marker = L.marker(coordinates, {
      draggable: true,
      icon: markerIcon
    }).addTo(maps[mapId]);

    // Event listener:
    // When clicking on map canvas, move both
    // map center and marker to that location
    // and update the location field
    maps[mapId].on('click', function(e) {
      maps[mapId].panTo(e.latlng);
      marker.setLatLng(e.latlng);
      updateHWLocationInput(e.latlng);
    });

    // Event listener:
    // After dragging the marker, update the location field
    marker.on('dragend', function(e) {
      updateHWLocationInput(marker.getLatLng());
    });
  }

  /**
   * Updates input field with coordinates string (e.g. `23.14124, 21.12312`)
   *
   * @param coordinates LatLng http://leafletjs.com/reference-1.0.0.html#latlng
   */
  function updateHWLocationInput(coordinates) {
    mw.log('HWLocationInput::updateHWLocationInput:');
    mw.log(coordinates);
    inputElement.val(coordinates.lat + ', ' + coordinates.lng);
  }

}(jQuery, mediaWiki) );
