requirejs.config({

  baseUrl: "/assets",

  paths: {
    // "text": "text",
    // "jquery": "jquery",
    // "jquery-cookie": "jquery-cookie",
    // "uri": "uri",
    // "underscore": "underscore",
    // "backbone": "backbone",
    // "bootstrap": "bootstrap",
    "marionette": "backbone.marionette"
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
    },
    'uri': {
      exports: 'URI'
    },
    'bootstrap': {
      deps: ['jquery']
    }
  }

});
