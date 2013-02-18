define(['vendor/jquery', "text!vendor/version.json"], function($, config) {
  config = $.parseJSON(config);

  var retryVersion = function() {
    // choose random delay between 3-8 minutes
    var randomDelay = (3 + (Math.random() * 5)) * 60 * 1000;
    setTimeout(checkVersion, randomDelay);
  };

  var checkVersion = function(dontRetry) {
    $.ajax({
      url: ['./js','/vendor/v','ersion.json'].join(''), // to get around cache busting
      success: function(newConfig) {
        if(newConfig.version != config.version) {
          refresh();
        }
        else if(!dontRetry) {
          retryVersion();
        }
      },
      error: retryVersion,
      dataType: 'json'
    });
  };

  var refresh = function() {
    // choose random delay between 0-1 minutes
    var randomDelay = Math.random() * 60 * 1000;
    setTimeout(function() {
      location.replace(location.href);
    }, randomDelay);
  }

  retryVersion();

  return {
    checkVersion: function() {
      checkVersion(true);
    }
  };
});
