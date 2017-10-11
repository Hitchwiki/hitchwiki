/**
 * Country ratings
 */

(function(mw, $) {
  mw.log('mw.HWMaps::CountryRating');

  /**
   * @class mw.HWMaps.CountryRating
   *
   * @constructor
   */
  function CountryRating() {
    mw.log('mw.HWMaps::CountryRating::constructor');
  }

  CountryRating.initialize = function() {
    mw.log('HWMaps::CountryRating::initialize');

    // When in debug mode, cache bust templates
    var cacheBust = mw.config.get('debug') ? mw.now() : mw.config.get('wgVersion');

    var getTatingTemplate = $.get(mw.config.get('wgExtensionAssetsPath') + '/HWMap/modules/templates/ext.HWMAP.Ratings.template.html?v=' + cacheBust);

    // Get average rating for the current article
    var getCountryRating = $.getJSON(mw.util.wikiScript('api'), {
      action: 'hwavgrating',
      format: 'json',
      pageid: mw.config.get('wgArticleId')
      // user_id: userId
    });

    $.when(getTatingTemplate, getCountryRating)
     .always(function(ratingTemplateHtml, countryRating) {

        if (!ratingTemplateHtml[0]) {
          mw.log.error('mw.HWMaps::CountryRating::initialize failed to load rating template. #j38ghg');
          return;
        }

        if (countryRating[0].error) {
          mw.log.error('mw.HWMaps::CountryRating::initialize failed to load country ratings. #9hghbh');
          mw.log.error(countryRating[0].error);
          return;
        }

        mw.log('mw.HWMaps::CountryRating::initialize data: #ug83hg');
        mw.log(countryRating[0]);

        var ractiveData = {
          userId: mw.config.get('wgUserId')
        };

        if (_.has(countryRating[0], 'query.ratings[0]')) {
          if (_.has(countryRating[0], 'query.ratings[0].rating_average')) {
            countryRating[0].query.ratings[0].average_label = mw.HWMaps.Spots.getRatingLabel(countryRating[0].query.ratings[0].rating_average);
          }
          if (_.has(countryRating[0], 'query.ratings[0].timestamp_user')) {
            countryRating[0].query.ratings[0].timestamp_user = mw.HWMaps.Spots.parseTimestamp(countryRating[0].query.ratings[0].timestamp_user);
          }
          if (_.has(countryRating[0], 'query.ratings[0].rating_user')) {
            countryRating[0].query.ratings[0].rating_user_label = mw.HWMaps.Spots.getRatingLabel(countryRating[0].query.ratings[0].rating_user);
          }
        } else {
          mw.log('mw.HWMaps::CountryRating::initialize no country ratings available. #gj93hv');
          countryRating[0].query.ratings[0] = {
            'average_label': 'Unknown'
          };
        }

        countryRating[0].query.ratings[0].id = mw.config.get('wgArticleId');

        ractiveData = _.merge(ractiveData, countryRating[0].query.ratings[0]);

        // Construct ractive template for rating widget
        // http://www.ractivejs.org/
        mw.HWMaps.ractive = new Ractive({
          el: 'hw-country-rating',
          template: ratingTemplateHtml[0],
          data: ractiveData
        });

        /*
        mw.HWMaps.ractive.set({
          average_label: countryRating[0].query.ratings[0].average_label,
          average_label: countryRating[0].query.ratings[0].average_label,
        });
        */

        // Initialize rating widgets on above template
        mw.HWMaps.Ratings.initRatingWidgets();
      });
  };

  // Export
  mw.HWMaps.CountryRating = CountryRating;

}(mediaWiki, jQuery));
