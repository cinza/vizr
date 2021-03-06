define([
  'vendor/jquery',
  'vendor/massrel',
  'template-renderer',
  'uilist',
  'vendor/twitter-text',
  'vendor/analytics'
], function($, massrel, templateRenderer, UIList) {

  function renderTemplate(context) {
    return templateRenderer.render(context);
  }

  function app() {
    var $elStream = $('#stream'),
        uiStream  = new UIList($elStream, {
          limit: 6,
          renderer: renderTemplate,
          beforeInsert: function ($el) {
            $el.css('opacity', 0).hide();
          },
          afterInsert: function ($el) {
            $el.slideDown(function () {
              $el.animate({
                opacity: 1
              });
            });
          }
        }),
        stream    = new massrel.Stream($elStream.attr('data-stream-name')),
        poller;

    poller = stream.poller({
      limit: 5,
      initial: {
        limit: 20
      },
      frequency: 15
    }).batch(function (data) {
      var self = this;

      // Is there data?
      if (data) {
        // Reverse data to get oldest first
        $.each(data.reverse(), function (i, status) {
          var context = massrel.Context.create(status); // Create the context

          if (context.known) { // Is a known status type
            if (!self.first) { // Is not the initial display, animate in one at a time
              self.timer = setTimeout(function () {
                uiStream.prepend(context);
              }, 3000 * i);
            } else {
              uiStream.prepend(context); // Initially load in all at once
            }
          }
        });
      }
    }).start();
  }

  $(document).ready(app);

});
