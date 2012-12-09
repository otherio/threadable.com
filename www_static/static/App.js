define(function(require){

  require('bootstrap');

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
    MainView:        require('views/MainView'),
    // LoggedInLayout: require('views/LoggedInLayout'),
    // LoggedOutView:  require('views/LoggedOutView')
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


  // Multify.bind('change:currentUser', function(currentUser){
  //   console.log('current users changed', arguments);

  //   App.mainRegion.close();


  //   if (currentUser){
  //     App.mainRegion.show(new App.views.LoggedInLayout({model: currentUser}));
  //   }else{
  //     App.mainRegion.show(new App.views.LoggedOutView);
  //     App.navRegion.currentView.on('login:clicked', function(){
  //       Multify.login('jared@change.org','password');
  //     });
  //   }
  // });


  App.on("initialize:after", function(options){
    if (Backbone.history) Backbone.history.start();

    Multify.initialize();

    App.navRegion.show(new App.views.NavView({model: App.Multify}));
    App.mainRegion.show(new App.views.MainView({model: App.Multify}));

    App.navRegion.currentView
      .on('login:clicked', function(){
        Multify.login('jared@change.org','password');
      })
      .on('logout:clicked', function(){
        Multify.logout();
      })
    ;

  });

  $(function(){
    App.start({});
  });

  return App;

});
