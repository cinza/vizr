({
  appDir: '../../',
  baseUrl: 'js',
  dir: '../../',
  optimize: 'none',
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
