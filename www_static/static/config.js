requirejs.config({
  paths: {
    "jquery": "vendor/jquery",
    "underscore": "vendor/underscore",
    "backbone": "vendor/backbone",
    "marionette": "vendor/backbone.marionette"
  },

  shim: {
    'underscore': {
      exports: '_'
    },
    'backbone': {
      deps: ['underscore', 'jquery'],
      exports: 'Backbone'
    }
  }

});
