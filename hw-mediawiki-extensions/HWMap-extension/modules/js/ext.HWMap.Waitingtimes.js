/**
 * Functions used for operations on spot Waitingtimes
 */

(function(mw, $) {
  mw.log('mw.HWMaps::Waitingtimes');

  /**
   * @class mw.HWMaps.Waitingtimes
   *
   * @constructor
   */
  function Waitingtimes() {
    mw.log('HWMaps::Waitingtimes::constructor');
  }

  /**
   * Load waiting times trough API
   * @return instance of jQuery.Promise
   */
  Waitingtimes.loadWaitingTimes = function(pageId) {
    mw.log('HWMaps::Waitingtimes::loadWaitingTimes: ' + pageId);

    // https://api.jquery.com/deferred.promise/
    var dfd = $.Deferred();

    $.getJSON(mw.util.wikiScript('api'), {
      action: 'hwgetwaitingtimes',
      format: 'json',
      pageid: pageId
    }).done(function(data) {
      if (data.error) {
        mw.log.error('mw.HWMaps.Waitingtimes.loadWaitingTimes: Error while accessing API. #39g883');
        mw.log.error(data.error);
        // Bubble notification
        // `mw.message` gets message translation, see `i18n/en.json`
        // `tag` replaces any previous bubbles by same tag
        // https://www.mediawiki.org/wiki/ResourceLoader/Modules#mediawiki.notify
        mw.notify(
          mw.message('hwmap-error-waitingtimes-load').text() + ' ' +
            mw.message('hwmap-please-try-again').text(),
          { tag: 'hwmap-error' }
        );
        return dfd.reject();
      }

      // Update spot with new label
      if (data.query.waiting_times && data.query.waiting_times.length) {
        for(var j = 0; j < data.query.waiting_times.length ; j++) {
          data.query.waiting_times[j].timestamp_label = mw.HWMaps.Spots.parseTimestamp(data.query.waiting_times[j].timestamp);
        }
      }

      dfd.resolve(data.query);
    })
    // https://api.jquery.com/deferred.fail/
    .fail(function() {
      mw.log.error('mw.HWMaps.Waitingtimes.loadWaitingTimes: Error while accessing API. #9857jf');
      // Bubble notification
      // `mw.message` gets message translation, see `i18n/en.json`
      // `tag` replaces any previous bubbles by same tag
      // https://www.mediawiki.org/wiki/ResourceLoader/Modules#mediawiki.notify
      mw.notify(
        mw.message('hwmap-error-waitingtimes-load').text() + ' ' +
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
   * Delete waiting time
   * @return instance of jQuery.Promise
   */
  Waitingtimes.deleteWaitingTime = function(waitingTimeId, pageId) {
    mw.log('HWMaps::Waitingtimes::deleteWaitingTime: ' + pageId);

    // https://api.jquery.com/deferred.promise/
    var dfd = $.Deferred();

    // Get token
    mw.HWMaps.Map.getToken(function(token) {
      if (!token) {
        mw.log.error('mw.HWMaps.Waitingtimes.deleteWaitingTime: no token. #fj12hb');
        return dfd.reject();
      }

      // Get a string for "Confirm removing waiting time?"
      var confirmMessage = mw.message('hwmap-confirm-removing-waitingtime').text();

      // Ask user for confirmation if to really delete waiting time
      if (window.confirm(confirmMessage)) {
        // Post new waiting time
        $.post(mw.util.wikiScript('api') + '?action=hwdeletewaitingtime&format=json', {
          waiting_time_id: waitingTimeId,
          token: token
        })
        .done(function(data) {

          if (data.error) {
            mw.log.error('mw.HWMaps.Waitingtimes.deleteWaitingTime: error via API when removing waiting time. #ugyfeg');
            mw.log.error(data.error);
            return dfd.reject();
          }

          if (typeof waitingTimesLoaded[pageId] !== 'undefined') {
            Waitingtimes.loadWaitingTimes(pageId, true);
          }

          if (data.query) {
            return dfd.resolve(data.query);
          }

          dfd.resolve();
        })
        .fail(function() {
          mw.log.error('mw.HWMaps.Waitingtimes.deleteWaitingTime: error via API when removing waiting time. #g38hhe');
          dfd.reject();
        });
      }
    });

    // Return the Promise so caller can't change the Deferred
    // https://api.jquery.com/deferred.promise/
    return dfd.promise();
  };

  /**
   * Add waiting time
   * @return instance of jQuery.Promise
   */
  Waitingtimes.addWaitingTime = function(newWaitingTime, pageId) {
    mw.log('HWMaps::Waitingtimes::addWaitingTime: ' + newWaitingTime);

    // https://api.jquery.com/deferred.promise/
    var dfd = $.Deferred();

    // Invalid waiting time
    if (isNaN(parseInt(newWaitingTime, 10))) {
      dfd.reject();
    } else {

      // Get token
      mw.HWMaps.Map.getToken(function(token) {
        if (!token) {
          mw.log.error('mw.HWMaps.Waitingtimes.addWaitingTime: no token (not logged in), cannot add waiting time. #fj39fh');
          return dfd.reject();
        }

        // Post new waiting time
        $.post(mw.util.wikiScript('api') + '?action=hwaddwaitingtime&format=json', {
          waiting_time: parseInt(newWaitingTime, 10), // in minutes
          pageid: pageId,
          token: token
        })
        .done(function(data) {

          /*
          if (!data.query) {
            mw.log.error('mw.HWMaps.Waitingtimes.addWaitingTime: did not receive any data trough API. #uudfgw');
            return dfd.reject();
          }
          */

          if (data.error) {
            mw.log.error('mw.HWMaps.Waitingtimes.addWaitingTime: error via API when adding waiting time. #yetqtq');
            mw.log.error(data.error);
            return dfd.reject();
          }

          // Resolve
          dfd.resolve(data.query);
        })
        .fail(function() {
          mw.log.error('mw.HWMaps.Waitingtimes.addWaitingTime: error via API when adding waiting time. #g38fgg');
          dfd.reject();
        });

      });
    }

    // Return the Promise so caller can't change the Deferred
    // https://api.jquery.com/deferred.promise/
    return dfd.promise();
  };


  /**
   * Toggles adding waiting time UI on/off for a spot
   */
  Waitingtimes.uiToggleAddingWaitingTime = function(spotObjectPath) {
    mw.log('mw.HWMaps::Waitingtimes::uiToggleAddingWaitingTime');
    // http://docs.ractivejs.org/latest/ractive-toggle
    mw.HWMaps.ractive.toggle(spotObjectPath + '._isAddingWaitingTimeVisible');
  };


  /**
   * Add waiting time to spot at city template
   */
  Waitingtimes.uiAddWaitingTime = function(newWaitingTimeHours, newWaitingTimeMins, pageId, spotObjectPath) {
    mw.log('mw.HWMaps::Waitingtimes::uiAddWaitingTime: ' + newWaitingTimeHours + 'h, ' + newWaitingTimeMins + 'm');

    // Turn empty string to `0` and parse everything else as an integer.
    // Sets `NaN` for other illegal strings
    newWaitingTimeHours = (newWaitingTimeHours === '') ? 0 : parseInt(newWaitingTimeHours);
    newWaitingTimeMins = (newWaitingTimeMins === '') ? 0 : parseInt(newWaitingTimeMins);

    if (isNaN(newWaitingTimeHours) || isNaN(newWaitingTimeMins)) {
      mw.log.error('mw.HWMaps::Waitingtimes::uiAddWaitingTime: Invalid waiting time. #9h2jff');
      // Bubble notification
      // `mw.message` gets message translation, see `i18n/en.json`
      // `tag` replaces any previous bubbles by same tag
      // https://www.mediawiki.org/wiki/ResourceLoader/Modules#mediawiki.notify
      mw.notify(
        mw.message('hwmap-missing-waitingtime').text(),
        { tag: 'hwmap-error' }
      );
      return;
    }

    var newWaitingTime = newWaitingTimeMins + (newWaitingTimeHours * 60);

    Waitingtimes.addWaitingTime(newWaitingTime, pageId).done(function(data) {
      mw.log('mw.HWMaps::Waitingtimes::uiAddWaitingTime done:');
      mw.log(data);

      // Update spot with new average
      if (_.has(data, 'average')) {
        mw.HWMaps.ractive.set(spotObjectPath + '.waiting_time_average', data.average);
      } else {
        mw.log.warn('mw.HWMaps::Waitingtimes::uiAddWaitingTime: Missing `average` from API response. #pjinq5');
      }

      // Update spot with new count
      if (_.has(data, 'count')) {
        mw.HWMaps.ractive.set(spotObjectPath + '.waiting_time_count', parseInt(data.count, 10));
      } else {
        mw.log.warn('mw.HWMaps::Waitingtimes::uiAddWaitingTime: Missing `count` from API response. #2jafff');
      }

      // Clear out input values
      mw.HWMaps.ractive.set(spotObjectPath + '._new_waiting_time_h', 0);
      mw.HWMaps.ractive.set(spotObjectPath + '._new_waiting_time_m', 0);

      // Hide adding waiting time input
      Waitingtimes.uiToggleAddingWaitingTime(spotObjectPath);
    })
    .fail(function() {
      // Bubble notification
      // `mw.message` gets message translation, see `i18n/en.json`
      // `tag` replaces any previous bubbles by same tag
      // https://www.mediawiki.org/wiki/ResourceLoader/Modules#mediawiki.notify
      mw.notify(
        mw.message('hwmap-error-waitingtimes-add').text() + ' ' +
          mw.message('hwmap-please-try-again').text(),
        { tag: 'hwmap-error' }
      );
    });
  };

  /**
   * Remove waiting time from a spot at the city template
   */
  Waitingtimes.uiDeleteWaitingTime = function(waitingTimeId, pageId, spotObjectPath) {
    mw.log('mw.HWMaps::Waitingtimes::uiDeleteWaitingTime: ' + waitingTimeId);
    Waitingtimes.deleteWaitingTime(waitingTimeId, pageId).done(function(data) {
      mw.log('mw.HWMaps::Waitingtimes::uiDeleteWaitingTime done:');
      mw.log(data);

      // Update spot with new average
      if (_.has(data, 'average')) {
        mw.HWMaps.ractive.set(spotObjectPath + '.waiting_time_average', data.average);
      }

      // Update spot with new count
      if (_.has(data, 'count')) {
        mw.HWMaps.ractive.set(spotObjectPath + '.waiting_time_count', parseInt(data.count, 10));
      }
    })
    .fail(function() {
      // Bubble notification
      // `mw.message` gets message translation, see `i18n/en.json`
      // `tag` replaces any previous bubbles by same tag
      // https://www.mediawiki.org/wiki/ResourceLoader/Modules#mediawiki.notify
      mw.notify(
        mw.message('hwmap-error-waitingtimes-remove').text() + ' ' +
          mw.message('hwmap-please-try-again').text(),
        { tag: 'hwmap-error' }
      );
    });
  };

  // Export
  mw.HWMaps.Waitingtimes = Waitingtimes;

}(mediaWiki, jQuery));
