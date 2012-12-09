define(function(require) {

  var
    Marionette = require('marionette'),
    splash_template = require('text!templates/splash.html');
    dashboard_template = require('text!templates/dashboard.html');

  return Marionette.ItemView.extend({

    getTemplate: function(){
      return _.template( this.model.get("currentUser") ? dashboard_template : splash_template );
    },

    modelEvents: {
      "change:currentUser": "render"
    }

  });
});
