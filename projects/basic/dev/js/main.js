/** 
 * @depends jquery.js
 * @depends handlebars.js
 * @depends prettydate.js
 * @depends twitter-text.js
 * @depends tweetriver.js
 * @depends tweetriver.handlebars.js
 * @depends uilist.js
 */
function app() {
  massrel.handlebars.register(Handlebars);

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

function templateFromScript(selector) {
  return Handlebars.compile($(selector).text());
};

$(document).ready(app);
