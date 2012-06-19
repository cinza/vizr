define([
  'vendor/jquery',
  'hbs!./templates/button-bar.html'
], function($, buttonBarTmpl) {

  return function($el, context) {
    var $tweet; 
    var args = '';

    if (!context) {
      return;
    }
    
    for (var key in context.tweet) {
      var value = context.tweet[key];

      if (!!value) {
        args += key + '=' + escape(value) + '&';
      }
    }
    
    context.tweet.args = args;

    $(buttonBarTmpl(context)).appendTo($el);
  };
  
});
