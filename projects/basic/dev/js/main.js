define([
  'vendor/jquery',
  'vendor/massrel',
  'vendor/handlebars',
  'vendor/twitter-text',
  'prettydate',
  'handlebars_helpers',
  'uilist'
], function($, massrel, Handlebars) {

  /* Compile Template */
  function templateFromScript(selector) {
    return Handlebars.compile($(selector).html());
  }

  function app() {
    var elStream = $('#stream');
    var uiStream = new massrel.UIList(elStream, {
      limit: 6,
      renderer: templateFromScript('#tmpl-status-twitter')
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
