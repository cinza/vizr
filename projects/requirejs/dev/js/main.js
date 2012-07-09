define([
  'vendor/jquery',
  'vendor/massrel',
  'hbs!templates/status-twitter.html',
  'uilist',
  'vendor/twitter-text',
  'analytics'
], function($, massrel, twitterTmpl, UIList) {

  function app() {
    var elStream = $('#stream');
    var uiStream = new UIList(elStream, {
      limit: 6,
      renderer: twitterTmpl
    });
    var stream = new massrel.Stream(elStream.attr('data-stream-name'));

    stream.poller({
      frequency: 15
    }).each(function(status) {
      var context = massrel.Context.create(status);
      if(context.known) {
        uiStream.prepend(context);
      }
    }).start();
  }

  $(document).ready(app);

});
