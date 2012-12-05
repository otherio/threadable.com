requirejs.config({
  paths: {
    "text": "vendor/text",
    "jquery": "vendor/jquery",
    "jquery-cookie": "vendor/jquery-cookie",
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
    },
    'jquery-cookie': {
      deps: ['jquery']
    }
  }

});
