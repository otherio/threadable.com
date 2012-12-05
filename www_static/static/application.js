define(function(require){

  var
    _ = require('underscore'),
    $ = require('jquery'),
    Marionette = require('marionette');

  Multify = require('Multify');

  App = new Marionette.Application();

  App.addRegions({
    navRegion: ".nav-region",
    mainRegion: ".main-region"
  });

  App.on("initialize:before", function(options){
    console.log('before init', options);
  });

  App.on("initialize:after", function(options){
    if (Backbone.history){
      Backbone.history.start();
    }
  });

  $(function(){
    App.start({});
  });

});
