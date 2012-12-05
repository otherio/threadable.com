define(function(require){

  var
    _              = require('underscore'),
    $              = require('jquery'),
    Marionette     = require('marionette'),
    NavView        = require('views/NavView'),
    LoggedInLayout = require('views/LoggedInLayout'),
    LoggedOutView  = require('views/LoggedOutView');

  App = new Marionette.Application();

  App.addRegions({
    navRegion: ".nav-region",
    mainRegion: ".main-region"
  });

  var loggedIn = false;

  App.on("initialize:after", function(options){
    if (Backbone.history){
      Backbone.history.start();
    }

    navView = new NavView({
      loggedIn: loggedIn,
    });
    App.navRegion.show(navView);

    var MainView = loggedIn ? LoggedInLayout : LoggedOutView;
    App.mainRegion.show(new MainView); // suck it Ian
  });

  $(function(){
    App.start({});
  });

  return App;

});
