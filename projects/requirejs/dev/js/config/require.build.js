({
  appDir: '../../',
  baseUrl: 'js',
  dir: '../../',

  optimize: 'none',

  paths: {
    hbs: 'vendor/hbs',
    templates: '../templates'
  },

  hbs: {
    disableI18n: true,
    helperPathCallback: function(name) {
      return '/templates/helpers/' + name + '.js';
    }
  },

  pragmasOnSave: {
    excludeHbsParser: true,
    excludeHbs: true,
    excludeAfterBuild: true
  },

  shim: {
    'vendor/handlebars': {
      exports: 'Handlebars'
    },
    'vendor/jquery': {
      exports: 'jQuery'
    }
  },

  modules: [
    {
      name: 'main',
      exclude: ['vendor/jquery']
    }
  ]
})
