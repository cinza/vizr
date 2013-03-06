define(['vendor/jquery', 'vendor/twitter-widgets'], function($) {
  // don't track anything if google analytics
  // is not on the page
  if(!window._gaq) { return; }

  // do not expose publicly
  // it is hacky
  function gaPush(args) {
    _gaq.push(args);
    if(window._gaq_b) {
      var args2 = args.slice(0);
      args2[0] = 'b.'+args2[0];
      _gaq.push(args2);
    };
  }

  function trackEvent() {
    var args = [].slice.call(arguments);
    args.unshift('_trackEvent');
    gaPush(args);
  }


  // FB events
  $('body').bind('fb:ready', function() {
    if(window.FB && FB.Event) {
      var likeToAnalytics = function(url) {
        trackEvent('fbintent', 'like', url);
      };
      var unlikeToAnalytics = function(url) {
        trackEvent('fbintent', 'unlike', url);
      };

      var sessionToAnalytics = function(name) {
        return function() {
          trackEvent('fbintent', 'auth', name);
        };
      };

      FB.Event.subscribe('edge.create', likeToAnalytics);
      FB.Event.subscribe('edge.remove', unlikeToAnalytics);
      FB.Event.subscribe('auth.login', sessionToAnalytics('login'));
      FB.Event.subscribe('auth.authResponseChange', sessionToAnalytics('authResponseChange'));
      FB.Event.subscribe('auth.statusChange', sessionToAnalytics('statusChange'));
      FB.Event.subscribe('auth.logout', sessionToAnalytics('logout'));
      FB.Event.subscribe('auth.prompt', sessionToAnalytics('prompt'));
    }
  });

  if(window.twttr) {
    // modified from from
    // https://dev.twitter.com/docs/intents/events
    twttr.ready(function() {
      var clickEventToAnalytics = function(intentEvent) {
        if(intentEvent) {
          var label = intentEvent.region;
          trackEvent('twitterintent', intentEvent.type, label);
        };
      };
     
      var tweetIntentToAnalytics = function(intentEvent) {
        if(intentEvent) {
          var label = 'tweet';
          trackEvent('twitterintent', intentEvent.type, label);
        };
      };
     
      var favIntentToAnalytics = function(intentEvent) {
        tweetIntentToAnalytics(intentEvent);
      };
     
      var retweetIntentToAnalytics = function(intentEvent) {
        if(intentEvent) {
          var label = intentEvent.data.source_tweet_id;
          trackEvent('twitterintent', intentEvent.type, label);
        };
      };
     
      var followIntentToAnalytics = function(intentEvent) {
        if(intentEvent) {
          var label = intentEvent.data.user_id + ' (' + intentEvent.data.screen_name + ')';
          trackEvent('twitterintent', intentEvent.type, label);
        };
      };

      twttr.events.bind('click',    clickEventToAnalytics);
      twttr.events.bind('tweet',    tweetIntentToAnalytics);
      twttr.events.bind('retweet',  retweetIntentToAnalytics);
      twttr.events.bind('favorite', favIntentToAnalytics);
      twttr.events.bind('follow',   followIntentToAnalytics);
    });
  }

  // tweet intent clicks
  $('body').delegate('[data-massrel-id] a', 'click', function() {
    var link = $(this),
        href = link.attr('href'),
        target = link.closest('[data-massrel-id]'),
        media = link.closest('.massrel-media').length > 0,
        status_id = target.attr('data-massrel-id'),
        network = target.closest('[data-massrel-network]').attr('data-massrel-network'),
        region = target.closest('[data-massrel-region]').attr('data-massrel-region');

    if(network) {
      status_id = network+'_'+status_id;
    }

    if(href) {
      if(href.indexOf('twitter.com') > -1) {
        if(media) {
          name = 'media';
        }
        else if(href.indexOf('/status/') > -1) { // permalink
          name = 'permalink';
        }
        else if(href.indexOf('/search?q=') > -1) { // hashtag
          name = 'hashtag';
        }
        else if(href.indexOf('tweet?in_reply_to=') > -1) { // reply
          name = 'reply';
        }
        else if(href.indexOf('intent/retweet') > -1) { // retweet
          name = 'rt';
        }
        else if(href.indexOf('intent/favorite') > -1) { // favorite
          name = 'fav';
        }
        else if(href.indexOf('intent/user') > -1) { // user intent
          if(link.hasClass('tweet-url')) {
            name = 'mention';  // mention
          }
          else {
            name = 'author'; // most likely author
          }
        }
        else {
          name = 'author'; // most likely author
        }
      }
      else if(href.indexOf('facebook.com') > -1) {
        if(media) {
          name = 'media';
        }
        else if(href.indexOf('/likes') > -1) {
          name = 'like';
        }
        else if(href.indexOf('/comments') > -1) {
          name = 'comment';
        }
        else if(href.indexOf('/posts/') > -1) {
          name = 'permalink';
        }
        else {
          name = 'author';
        }
      }
      else {
        // status link
        name = 'link';
      }

      if(name) {
        trackEvent(network === 'twt' ? 'tweetaction' : network+'action', name, region || 'other');
      }
    }
  });

  return {
    trackEvent: trackEvent
  };

});
