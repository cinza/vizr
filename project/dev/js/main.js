massrel.handlebars.register(Handlebars);

function app() {
  var elStream = $('#stream');
  var uiStream = new UIList(elStream, {
    limit: 6,
    renderer: templateFromScript('#tmpl-status-twitter')
  });
  var stream = new massrel.Stream(elStream.attr('data-stream-name'));

  stream.poller({
    frequency: 15
  }).each(function(status) {
    var context = massrel.handlebars.prepare_context(status);
    if(context.known) {
      uiStream.prepend(context);
    }
  }).start();
}

function templateFromScript(selector) {
  return Handlebars.compile($(selector).text());
};

$(document).ready(app);
