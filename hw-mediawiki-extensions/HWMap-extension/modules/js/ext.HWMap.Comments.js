/**
 * Functions used for operations on spot Comments
 */

(function(mw, $) {
  mw.log('mw.HWMaps::Comments');

  /**
   * @class mw.HWMaps.Comments
   *
   * @constructor
   */
  function Comments() {
    mw.log('HWMaps::Comments::constructor');
  }

  /**
   *
   * @static
   * @return instance of jQuery.Promise
   */
  Comments.loadComments = function(pageId) {
    mw.log('mw.HWMaps.Comments::loadComments: ' + pageId);

    // https://api.jquery.com/deferred.promise/
    var dfd = $.Deferred();

    $.getJSON(mw.util.wikiScript('api'), {
      action: 'hwgetcomments',
      format: 'json',
      pageid: pageId
    }).done(function(data) {
      if (data.error) {
        mw.log.error('mw.HWMaps.Comments::loadComments: Error while accessing comments API. #j39235');
        mw.log.error(data.error);
        return dfd.reject();
      }

      if (data.query.comments && data.query.comments.length) {
        for (var j = 0; j < data.query.comments.length ; j++) {
          data.query.comments[j].timestamp_label = mw.HWMaps.Spots.parseTimestamp(data.query.comments[j].timestamp);
        }
      }

      dfd.resolve(data.query);
    }).fail(function() {
      mw.log.error('mw.HWMaps.Comments::loadComments: Error while accessing comments API. #ig8ryb');
      return dfd.reject();
    });

    // Return the Promise so caller can't change the Deferred
    // https://api.jquery.com/deferred.promise/
    return dfd.promise();
  };

  /**
   *
   * @static
   * @return instance of jQuery.Promise
   */
  Comments.deleteComment = function(commentId) {
    mw.log('mw.HWMaps.Comments::deleteComment: ' + commentId);

    // https://api.jquery.com/deferred.promise/
    var dfd = $.Deferred();

    // Get token
    mw.HWMaps.Map.getToken(function(token) {
      if (!token) {
        mw.log.error('HWMaps::Comments::deleteComment: Not logged in, cannot remove comment. #gj93h4');
        return dfd.reject();
      }

      if (!window.confirm('Are you sure you want to delete this comment?')) {
        mw.log('HWMaps::Comments::deleteComment: User cancelled removing the comment. #gdsgj9');
        return dfd.resolve();
      }

      // Post new rating
      $.post(mw.util.wikiScript('api') + '?action=hwdeletecomment&format=json', {
        comment_id: commentId,
        token: token
      }).done(function(data) {
        if (data.error) {
          mw.log.error('mw.HWMaps.Comments::deleteComment: Error while accessing comments API. #qqrfbv');
          mw.log.error(data.error);
          return dfd.reject();
        }

        dfd.resolve(data.query);

      }).fail(function() {
        mw.log.error('mw.HWMaps.Comments::deleteComment: Error while accessing comments API. #qteefb');
        dfd.reject();
      });

    });

    // Return the Promise so caller can't change the Deferred
    // https://api.jquery.com/deferred.promise/
    return dfd.promise();
  };

  /**
   *
   * @static
   * @return instance of jQuery.Promise
   */
  Comments.addComment = function(commentText, pageId) {
    mw.log('mw.HWMaps.Comments::addComment: ' + pageId);

    // https://api.jquery.com/deferred.promise/
    var dfd = $.Deferred();

    mw.HWMaps.Map.getToken(function(token) {
      if (!token) {
        mw.log.error('HWMaps::Comments::addComment: Not logged in, cannot post new comment. #g93ygf');
        return dfd.reject();
      }

      if (!commentText || !commentText.trim().length) {
        return dfd.reject();
      }

      // @TODO:
      //commentText = commentText.replace(/\n/g, '<br/>');

      //Post new rating
      $.post(mw.util.wikiScript('api') + '?action=hwaddcomment&format=json', {
        commenttext: commentText,
        pageid: pageId,
        token: token
      }).done(function(data) {
        if (data.error) {
          mw.log.error('mw.HWMaps.Comments::addComment: Error while accessing comments API. #gi2hhg');
          mw.log.error(data.error);
          // Bubble notification
          // `mw.message` gets message translation, see `i18n/en.json`
          // `tag` replaces any previous bubbles by same tag
          // https://www.mediawiki.org/wiki/ResourceLoader/Modules#mediawiki.notify
          mw.notify(
            mw.message('hwmap-error-rating-add').text() + ' ' +
              mw.message('hwmap-please-try-again').text(),
            { tag: 'hwmap-error' }
          );
          return dfd.reject();
        }

        dfd.resolve(data.query);

      }).fail(function() {
        mw.log.error('mw.HWMaps.Comments::addComment: Error while accessing comments API. #3982y4');
        // Bubble notification
        // `mw.message` gets message translation, see `i18n/en.json`
        // `tag` replaces any previous bubbles by same tag
        // https://www.mediawiki.org/wiki/ResourceLoader/Modules#mediawiki.notify
        mw.notify(
          mw.message('hwmap-error-comment-add').text() + ' ' +
            mw.message('hwmap-please-try-again').text(),
          { tag: 'hwmap-error' }
        );
        dfd.reject();
      });

    });

    // Return the Promise so caller can't change the Deferred
    // https://api.jquery.com/deferred.promise/
    return dfd.promise();
  };

  /**
   * Remove comment
   */
  Comments.uiDeleteComment = function(commentId, spotObjectPath) {
    mw.log('mw.HWMaps::Comments::uiDeleteComment: ' + commentId);

    // @TODO: remove comment at this point from Ractive

    Comments.deleteComment(commentId).done(function(data) {
      mw.log('mw.HWMaps::Comments::uiDeleteComment: done');
      mw.log(data);

      // Update spot with real count
      if (_.has(data, 'count')) {
        mw.HWMaps.ractive.set(spotObjectPath + '.comment_count', parseInt(data.count, 10));
      }

      // Refresh comments
      Comments.loadComments(pageId).done(function(data) {
        mw.log('mw.HWMaps::Comments::uiDeleteComment -> load new comments');
        mw.log(data);

        if (_.has(data, 'comments')) {
          mw.HWMaps.ractive.set(spotObjectPath + '.comments', data.comments);
        }

      });
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
   * Add comment
   */
  Comments.uiAddComment = function(commentText, pageId, spotObjectPath) {
    mw.log('mw.HWMaps::Comments::uiAddComment: ' + pageId);
    mw.log(commentText);

    // @TODO: add comment at this point to Ractive

    // Lock UI while adding new comment
    mw.HWMaps.ractive.set(spotObjectPath + '._isAddingComment', true);

    Comments.addComment(commentText, pageId).done(function(data) {
      mw.log('mw.HWMaps::Comments::uiAddComment: done');
      mw.log(data);

      // Update spot with real count
      if (_.has(data, 'count')) {
        mw.HWMaps.ractive.set(spotObjectPath + '.comment_count', parseInt(data.count, 10));
      }

      // Refresh comments
      Comments.loadComments(pageId).done(function(data) {
        mw.log('mw.HWMaps::Comments::uiAddComment -> load new comments');
        mw.log(data);

        if (_.has(data, 'comments')) {
          mw.HWMaps.ractive.set(spotObjectPath + '.comments', data.comments);
        }

        // Empty comment field and enable inputs
        mw.HWMaps.ractive.set(spotObjectPath + '._new_comment', '');

        // Unlock UI
        mw.HWMaps.ractive.set(spotObjectPath + '._isAddingComment', false);

      });

    });
  };

  // Export
  mw.HWMaps.Comments = Comments;

}(mediaWiki, jQuery));
