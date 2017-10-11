/**
 * Functions used for operations on spot ratings
 */

(function(mw, $) {
  mw.log('mw.HWMaps::Ratings');

  /**
   * @class mw.HWMaps.Ratings
   *
   * @constructor
   */
  function Ratings() {
    mw.log('HWMaps::Ratings::constructor');
  }

  /**
   * Load ratings
   *
   * @static
   * @return instance of jQuery.Promise
   */
  Ratings.loadRatings = function(pageId) {
    mw.log('mw.HWMaps.Ratings::loadRatings: ' + pageId);

    // https://api.jquery.com/deferred.promise/
    var dfd = $.Deferred();

    $.getJSON(mw.util.wikiScript('api'), {
      action: 'hwgetratings',
      format: 'json',
      pageid: pageId
    }).done(function(data) {
      mw.log('mw.HWMaps.Ratings::loadRatings done:');
      mw.log(data);
      if (data.error) {
        mw.log.error('mw.HWMaps.Ratings::loadRatings: Error while loading ratings via API. #g98ghhg');
        // Bubble notification
        // `mw.message` gets message translation, see `i18n/en.json`
        // `tag` replaces any previous bubbles by same tag
        // https://www.mediawiki.org/wiki/ResourceLoader/Modules#mediawiki.notify
        mw.notify(
          mw.message('hwmap-error-rating-load').text() + ' ' +
            mw.message('hwmap-please-try-again').text(),
          { tag: 'hwmap-error' }
        );
        return dfd.reject();
      }

      // Update spot with labels
      if (data.query.ratings && data.query.ratings.length) {
        for (var j = 0; j < data.query.ratings.length ; j++) {
          data.query.ratings[j].rating_label = mw.HWMaps.Spots.getRatingLabel(data.query.ratings[j].rating);
          data.query.ratings[j].timestamp_label = mw.HWMaps.Spots.parseTimestamp(data.query.ratings[j].timestamp);
        }
      }

      dfd.resolve(data.query);
    })
    // https://api.jquery.com/deferred.fail/
    .fail(function() {
      mw.log.error('mw.HWMaps.Ratings::loadRatings: Error while loading ratings via API. #g38hh1');
      // Bubble notification
      // `mw.message` gets message translation, see `i18n/en.json`
      // `tag` replaces any previous bubbles by same tag
      // https://www.mediawiki.org/wiki/ResourceLoader/Modules#mediawiki.notify
      mw.notify(
        mw.message('hwmap-error-rating-load').text() + ' ' +
          mw.message('hwmap-please-try-again').text(),
        { tag: 'hwmap-error' }
      );
      dfd.reject();
    });

    // Return the Promise so caller can't change the Deferred
    // https://api.jquery.com/deferred.promise/
    return dfd.promise();
  };

  /**
   * Add rating
   *
   * @static
   * @return instance of jQuery.Promise
   */
  Ratings.addRating = function(newRating, id) {
    mw.log('HWMaps::Ratings::addRating');

    // https://api.jquery.com/deferred.promise/
    var dfd = $.Deferred();

    // Get Mediawiki token
    mw.HWMaps.Map.getToken(function(token) {
      if (!token) {
        mw.log.error('HWMaps::Ratings::addRating: Not logged in, cannot add rating. #jgg8FF');
        return dfd.reject();
      }
      // Post new rating
      $.post(mw.util.wikiScript('api') + '?action=hwaddrating&format=json', {
        rating: newRating,
        pageid: id,
        token: token
      }).done(function(data) {
        if (data.error) {
          mw.log.error('mw.HWMaps.Ratings::addRating: Error while accessing rating API. #399ggd');
          mw.log.error(data.error);
          return dfd.reject();
        }
        dfd.resolve(data.query);
      })
      // https://api.jquery.com/deferred.fail/
      .fail(function() {
        mw.log.error('mw.HWMaps.Ratings::addRating: Error while accessing rating API. #g23igh');
        dfd.reject();
      });
    });

    // Return the Promise so caller can't change the Deferred
    // https://api.jquery.com/deferred.promise/
    return dfd.promise();
  };

  /**
   * Delete rating
   *
   * @static
   * @return instance of jQuery.Promise
   */
  Ratings.deleteRating = function(pageId) {
    mw.log('HWMaps::Ratings::deleteRating');

    // https://api.jquery.com/deferred.promise/
    var dfd = $.Deferred();

    // Get token
    mw.HWMaps.Map.getToken(function(token) {

      if (!token) {
        mw.log.error('HWMaps::Ratings::deleteRating: Not logged in, cannot delete rating. #i30Fff');
        return dfd.reject();
      }

      $.post(mw.util.wikiScript('api') + '?action=hwdeleterating&format=json', {
        pageid: pageId,
        token: token
      }).done(function(data) {

        if (data.error) {
          mw.log.error('mw.HWMaps.Ratings::deleteRating: Error while accessing rating API. #g2i311');
          mw.log.error(data.error);
          return dfd.reject();
        }

        dfd.resolve(data.query);
      })
      .fail(function() {
        mw.log.error('mw.HWMaps.Ratings::deleteRating: Error while accessing rating API. #93t842');
        return dfd.reject();
      });
    });

    // Return the Promise so caller can't change the Deferred
    // https://api.jquery.com/deferred.promise/
    return dfd.promise();
  };

  /**
   *
   */
  Ratings.uiAddRating = function(newRating, pageId, spotObjectPath) {

    // Validate new rating
    newRating = parseInt(newRating, 10) || 0;

    mw.log('mw.HWMaps::Ratings::uiAddRating: ' + pageId + ' (' + newRating + ')');

    Ratings.addRating(newRating, pageId).done(function(response) {

      // Ensure that even if average rating goes bad after deleting rating,
      // Spot info won't be toggled hidden
      mw.HWMaps.ractive.toggle(spotObjectPath + '._isBadSpotVisible');

      mw.HWMaps.ractive.set(spotObjectPath + '.rating_user', newRating);
      mw.HWMaps.ractive.set(spotObjectPath + '.rating_user_label', mw.HWMaps.Spots.getRatingLabel(newRating));

      if (_.has(response, 'timestamp')) {
        mw.HWMaps.ractive.set(spotObjectPath + '.timestamp_user', mw.HWMaps.Spots.parseTimestamp(response.timestamp));
      }

      if (_.has(response, 'average')) {
        mw.HWMaps.Spots.updateSpotMarker(pageId, response.average);
        mw.HWMaps.ractive.set(spotObjectPath + '.rating_average', parseFloat(response.average));
        mw.HWMaps.ractive.set(spotObjectPath + '.average_label', mw.HWMaps.Spots.getRatingLabel(response.average));
      }

      if (_.has(response, 'count')) {
        mw.HWMaps.ractive.set(spotObjectPath + '.rating_count', parseInt(response.count, 10));
      }
    })
    .fail(function() {
      // Bubble notification
      // `mw.message` gets message translation, see `i18n/en.json`
      // `tag` replaces any previous bubbles by same tag
      // https://www.mediawiki.org/wiki/ResourceLoader/Modules#mediawiki.notify
      mw.notify(
        mw.message('hwmap-error-rating-add').text() + ' ' +
          mw.message('hwmap-please-try-again').text(),
        { tag: 'hwmap-error' }
      );
    });
  };

  /**
   * Remove rating
   */
  Ratings.uiDeleteRating = function(pageId, spotObjectPath) {
    mw.log('mw.HWMaps::Ratings::uiDeleteRating: ' + pageId);

    Ratings.deleteRating(pageId).done(function(response) {
      if (response) {

        // Ensure that even if average rating goes bad after deleting rating,
        // Spot info won't be toggled hidden
        mw.HWMaps.ractive.toggle(spotObjectPath + '._isBadSpotVisible');

        // Update spot with new statistics
        mw.HWMaps.ractive.set(spotObjectPath + '.timestamp_user', 0);
        mw.HWMaps.ractive.set(spotObjectPath + '.rating_user', 0);
        mw.HWMaps.ractive.set(spotObjectPath + '.rating_user_label', null);
        mw.HWMaps.ractive.set(spotObjectPath + '.rating_average', response.average || 0);
        mw.HWMaps.ractive.set(spotObjectPath + '.rating_count', response.count || 0);
        mw.HWMaps.ractive.set(spotObjectPath + '.average_label', mw.HWMaps.Spots.getRatingLabel(response.average));

        // Update marker on the map
        mw.HWMaps.Spots.updateSpotMarker(pageId, response.average || 0);
      }
    })
    .fail(function() {
      // Bubble notification
      // `mw.message` gets message translation, see `i18n/en.json`
      // `tag` replaces any previous bubbles by same tag
      // https://www.mediawiki.org/wiki/ResourceLoader/Modules#mediawiki.notify
      mw.notify(
        mw.message('hwmap-error-rating-delete').text() + ' ' +
          mw.message('hwmap-please-try-again').text(),
        { tag: 'hwmap-error' }
      );
    });
  };


  /**
   * Init rating widgets on current page
   */
  Ratings.initRatingWidgets = function() {
    mw.log('HWMaps::Ratings::initRatingWidgets');

    $('.hw-your-rate').hide();

    $('.hw-rating-widget .hw-rate').click(function(e) {
      e.preventDefault();
      $('.hw-your-rate').hide();
      //$('.hw-rate').show();
      //$(this).hide();
      var id = $(this).attr('id').replace(/hw-rate_/, '');

      $('#hw-your_rate_' + id).show();
    });

    $(document).mouseup(function(e) {
      var container = $('.hw-rating-widget .hw-rate');

      if (!container.is(e.target) // if the target of the click isn't the container...
          && container.has(e.target).length === 0) // ... nor a descendant of the container
      {
        $('.hw-your-rate').hide();
        //$('.hw-rate').show();
      }
    });
  };

  // Export
  mw.HWMaps.Ratings = Ratings;

}(mediaWiki, jQuery));
