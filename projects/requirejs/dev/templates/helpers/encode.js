define(['vendor/handlebars'], function(Handlebars) {

  function encode(text) {

    return encodeURIComponent(text);

  }

  Handlebars.registerHelper('encode', encode);

  return encode;

});