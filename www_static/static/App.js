define(function(require){

  var
    _ = require('underscore'),
    $ = require('jquery'),
    Marionette = require('marionette'),
    NavView = require('views/NavView');

  App = new Marionette.Application();

  App.addRegions({
    navRegion: ".nav-region",
    mainRegion: ".main-region"
  });

  App.on("initialize:after", function(options){
    if (Backbone.history){
      Backbone.history.start();
    }

    navView = new NavView();
    App.navRegion.show(navView);
  });

  $(function(){
    App.start({});
  });

  return App;

});
