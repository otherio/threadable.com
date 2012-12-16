define(function(require){

  require('bootstrap');

  var
    _               = require('underscore'),
    $               = require('jquery'),
    Backbone        = require('backbone'),
    Marionette      = require('marionette'),
    Multify         = require('multify'),
    LoggedOutRouter = require('logged_out/Router'),
    LoggedInRouter  = require('logged_in/Router'),
    Layout          = require('views/Layout');

  App = new Marionette.Application();

  App.Multify = Multify;
  Backbone.sync = Multify.sync;


  App.addInitializer(function(){
    App.layout = new Layout().render();
    Multify.initialize();
  });

  Multify.on('change:currentUser', function(currentUser, previousUser){
    console.log('resetting routes', arguments);

    var loggedIn = !!currentUser;

    if (Backbone.history) Backbone.history.handlers = [];

    if (loggedIn){
      $('body').addClass('logged-in').removeClass('logged-out');
      App.router = new LoggedInRouter;
      setTimeout(function(){
        // simulate a slow server to see loading state
        App.Multify.get('currentUser').projects.fetch();
      }, 500);
    }else{
      $('body').addClass('logged-out').removeClass('logged-in');
      App.router = new LoggedOutRouter;
    }

    if (Backbone.History.started)
      Backbone.history.loadUrl(location.pathname.slice(1));
    else
      Backbone.history.start({pushState: true});
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

// MISC (need to stick these some place)

// for debugging
function inspector(name){
  return function(){
    console.log(name, this, arguments);
  }
}

$(document).on('click', 'a[href=""],a[href="#"]', function(event){
  event.preventDefault();
});

$(document).on('click', 'a[href]', function(event){
  var href = $(this).attr('href');
  if (href[0] === '/'){
    event.preventDefault();
    App.router.navigate(href, {trigger: true});
