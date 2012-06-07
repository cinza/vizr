define(['vendor/handlebars', 'vendor/twitter-text'], function(Handlebars) {

  function autoLink(text) {
    var options = {
      target: '_blank',
      usernameIncludeSymbol: true
    };

    if(this.source.twitter) {
      if(window.twttr && twttr.tfw) {
        // only use intent urls for mentions if
        // twitter for websites is found on the page
        options.usernameUrlBase = 'https://twitter.com/intent/user?screen_name=';
      }

      if(this.status.entities) {
        if(this.status.entities.urls) {
          options.urlEntities = this.status.entities.urls;
        }
        if(this.status.entities.media) {
          options.urlEntities = (options.urlEntities || []).concat(this.status.entities.media);
        }
      }
      return twttr.txt.autoLink(text, options);
    }

    return twttr.txt.autoLinkUrlsCustom(text, options);
  }

  Handlebars.registerHelper('autoLink', autoLink);

  return autoLink;
});

