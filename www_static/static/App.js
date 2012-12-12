define(function(require){

  var
    _              = require('underscore'),
    $              = require('jquery'),
    Backbone       = require('backbone'),
    Multify        = require('multify'),
    Marionette     = require('marionette'),
    NavView        = require('views/NavView'),
    LoggedInLayout = require('views/LoggedInLayout'),
    LoggedOutView  = require('views/LoggedOutView'),
    session        = require('session'),
    User           = require('models/User');

  Backbone.sync = Multify.sync;

  App = new Marionette.Application();

  App.addRegions({
    navRegion: ".nav-region",
    mainRegion: ".main-region"
  });


  App.addInitializer(function() {
    console.log('setting session event handler');
    session.on('change reset', function(e) {
      var user = session.get('user');
      var cu = Multify.set('current_user', user ? new User(user) : undefined);
      console.log('current user', cu);
    });
    session.fetch();
  });

  App.on("initialize:after", function(options){
    if (Backbone.history){
      Backbone.history.start();
    }

    navView = new NavView();

    App.navRegion.show(navView);

    var MainView = !!Multify.get('current_user') ? LoggedInLayout : LoggedOutView;
    App.mainRegion.show(new MainView);
  });

  $(function(){
    if(window.location.href.match(/\/spec\??/)) {
      console.log('Would start(), but assuming testing')
    } else {
      App.start({});
    }
  });

  return App;

});
