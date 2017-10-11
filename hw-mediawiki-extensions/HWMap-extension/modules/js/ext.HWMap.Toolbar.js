/**
 * Add a simple toolbar with buttons like "Add new place" and "World map"
 * to "sidebar maps" at City/Area/Country articles.
 *
 * Relies to OOjs UI/Widgets
 * https://www.mediawiki.org/wiki/OOjs_UI/Widgets/Buttons_and_Switches
 */
(function(mw, $) {

  mw.log('HWMaps::Toolbar');

  var $hwMapToolbar;

  /**
   * @class mw.HWMaps.Toolbar
   *
   * @constructor
   */
  function Toolbar() {

  }

  /**
   * Initialize
   */
  Toolbar.initialize = function() {
    $hwMapToolbar = $('.hw-map-toolbar');
    // Add buttons inside the toolbar if it exists
    if ($hwMapToolbar.length) {
      initializeWorldMapButton();
      initializeNewSpotButton();
    }
  }

  /**
   * "World map" button
   */
  function initializeWorldMapButton() {
    mw.log('HWMaps::Toolbar::initializeWorldMapButton');
    var worldMapButton = new OO.ui.ButtonWidget({
      label: 'World map',
      // icon: 'Map',
      href: mw.config.get('wgArticlePath').replace('$1', 'Special:HWMap')
    });
    $hwMapToolbar.append(worldMapButton.$element);
  }

  /**
   * "Add new spot" button
   */
  function initializeNewSpotButton() {
    mw.log('HWMaps::Toolbar::initializeNewSpotButton');
    var newSpotButton = new OO.ui.ButtonWidget({
      label: 'Add new spot',
      // icon: 'MapPinAdd',
      // `#add` in the URL initializes adding a new spot at `HWMap` page
      href: mw.config.get('wgArticlePath').replace('$1', 'Special:HWMap#hwmap-add')
    });
    $hwMapToolbar.append(newSpotButton.$element);
  }

  mw.HWMaps.Toolbar = Toolbar;

}(mediaWiki, jQuery));
