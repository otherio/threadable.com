define(function(require){

  var
    _              = require('underscore'),
    $              = require('jquery'),
    Backbone       = require('backbone'),
    Marionette     = require('marionette'),
    Multify        = require('multify');

  App = new Marionette.Application();

  App.Multify = Multify;
  Backbone.sync = Multify.sync;

  App.views = {
    NavView:        require('views/NavView'),
    LoggedInLayout: require('views/LoggedInLayout'),
    LoggedOutView:  require('views/LoggedOutView')
  };

  App.models = {
    User:    require('models/User'),
    Project: require('models/Project'),
    Task:    require('models/Task')
  };

  App.addRegions({
    navRegion: ".nav-region",
    mainRegion: ".main-region"
  });


  Multify.bind('change:currentUser', function(currentUser){
    console.log('current users changed', arguments);

    App.navRegion.close();
    App.mainRegion.close();

    if (currentUser){
      App.navRegion.show(new App.views.NavView({model: currentUser}));
      App.mainRegion.show(new App.views.LoggedInLayout({model: currentUser}));
      App.navRegion.currentView.on('login:clicked', function(){
        Multify.login('jared@change.org','password');
      });
    }else{
      App.navRegion.close();
      App.mainRegion.close();
      App.navRegion.show(new App.views.NavView);
      App.mainRegion.show(new App.views.LoggedOutView);
    }
  });


  App.on("initialize:after", function(options){
    if (Backbone.history) Backbone.history.start();

    Multify.initialize();

  });

  $(function(){
    App.start({});
  });

  return App;

});
