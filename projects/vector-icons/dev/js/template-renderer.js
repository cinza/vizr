define([
  'vendor/jquery',
  'vendor/massrel',
  'hbs!templates/status-twitter.html',
  'hbs!templates/status-facebook.html',
  'hbs!./templates/status-instagram.html',
  'hbs!./templates/status-google.html',
  'prettyDate',
  'vendor/twitter-text'
], function($, massrel, twitterTmpl, facebookTmpl, instagramTmpl, googleTmpl, prettyDate) {

  var templates = {
    CONFIG: {
        action_label: true,
        verified: true,
        small_avatar: false,
        full_width_text: false,
        multiline_name: false,
        always_show_intents: false,
        never_show_intents: false, // "never" takes precidence over "always"
        right_aligned_intents: false,
        location: false,
        details_link: true,
        permalink: true,
        full_details: false
    },
    render: function(context, config) {
      config = $.extend({}, templates.CONFIG, config || {});
      context.config = config;

      var statusCss = [];

      if(!config.action_label) {
        statusCss.push('massrel-no-action-label');
      }

      if(config.small_avatar) {
        statusCss.push('massrel-small-avatar');
      }

      if(config.full_width_text) {
        statusCss.push('massrel-full-width');
      }

      if(config.multiline_name) {
        statusCss.push('massrel-different-lines');
      }

      if(config.always_show_intents) {
        statusCss.push('massrel-show-intents');
      }

      if(config.right_aligned_intents) {
        statusCss.push('massrel-right-intents');
      }

      if(!config.details_link) {
        statusCss.push('massrel-no-details');
      }

      if(status && status.entities && status.entities.media) {
        context.media = $.map(status.entities.media, function(media) {
          return media.media_url;
        });
      }

      context.status_css = statusCss.join(' ');

      var html;
      if(context.source.twitter) {
        context.formattedDate = {
          display: prettyDate(context.status.created_at, false),
          full: prettyDate(context.status.created_at, true),
          timestamp: context.status.created_at
        };
        html = twitterTmpl(context);
      }
      else if(context.source.facebook) {
        context.formattedDate = {
          display: prettyDate(context.status.created_time, false),
          full: prettyDate(context.status.created_time, true),
          timestamp: context.status.created_time
        };
        html = facebookTmpl(context);
      }
      else if(context.source.instagram) {
        var d = new Date(context.status.created_time * 1000); // UNIX timestamp in ms
        context.formattedDate = {
          display: prettyDate(d, false),
          full: prettyDate(d, true),
          timestamp: d.toString()
        };

        // change profile avatars to go through https proxy
        context.status.user.profile_picture = '//i.embed.ly/1/image?key=fd577f7497bf11e0b95d4040d3dc5c07&url='+encodeURIComponent(context.status.user.profile_picture);
        if(context.status.caption) {
          context.status.caption.from.profile_picture = '//i.embed.ly/1/image?key=fd577f7497bf11e0b95d4040d3dc5c07&url='+encodeURIComponent(context.status.caption.from.profile_picture);
        }

        html = instagramTmpl(context);
      }
      else if(context.source.google) {
        var d = context.status.published;
        context.formattedDate = {
          display: prettyDate(d, false),
          full: prettyDate(d, true),
          timestamp: d
        };
        html = googleTmpl(context);
      }
      else {
        // unknown context
        if(window.console && console.log) {
          console.log('unknown render context', context);
        }
      }

      return html;
    }
  };

  updateTime = function() {
    if(document.querySelectorAll) {
      var elems = document.querySelectorAll('[data-date]');
      for(var i = 0, len = elems.length; i < len; i++) {
        var elem = elems[i];
        if(elem) {
          var date = elem.getAttribute('data-date');
          elem.innerHTML = prettyDate(date);
        }
      }
      setTimeout(updateTime, 30e3);
    }
  };

  updateTime();

  return templates;
});
