;(function() {
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
      _gaq_b.push(args);
    };
  }

  if(window.twttr) {
    // modified from from
    // https://dev.twitter.com/docs/intents/events
    twttr.ready(function() {
      var clickEventToAnalytics = function(intentEvent) {
        if(intentEvent) {
          var label = intentEvent.region;
          gaPush(['_trackEvent', 'twitterintent', intentEvent.type, label]);
        };
      };
     
      var tweetIntentToAnalytics = function(intentEvent) {
        if(intentEvent) {
          var label = 'tweet';
          gaPush(['_trackEvent', 'twitterintent', intentEvent.type, label]);
        };
      };
     
      var favIntentToAnalytics = function(intentEvent) {
        tweetIntentToAnalytics(intentEvent);
      };
     
      var retweetIntentToAnalytics = function(intentEvent) {
        if(intentEvent) {
          var label = intentEvent.data.source_tweet_id;
          gaPush(['_trackEvent', 'twitterintent', intentEvent.type, label]);
        };
      };
     
      var followIntentToAnalytics = function(intentEvent) {
        if(intentEvent) {
          var label = intentEvent.data.user_id + ' (' + intentEvent.data.screen_name + ')';
          gaPush(['_trackEvent', 'twitterintent', intentEvent.type, label]);
        };
      };

      twttr.events.bind('click',    clickEventToAnalytics);
      twttr.events.bind('tweet',    tweetIntentToAnalytics);
      twttr.events.bind('retweet',  retweetIntentToAnalytics);
      twttr.events.bind('favorite', favIntentToAnalytics);
      twttr.events.bind('follow',   followIntentToAnalytics);
    });
  }

})();



