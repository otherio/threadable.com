define(function(require){

  require('bootstrap');

  var
    _               = require('underscore'),
    $               = require('jquery'),
    Backbone        = require('backbone'),
    Marionette      = require('marionette'),
    multify         = require('multify'),
    LoggedOutRouter = require('logged_out/Router'),
    LoggedInRouter  = require('logged_in/Router'),
    Layout          = require('views/Layout');

  App = new Marionette.Application();

  App.multify = multify;
  Backbone.sync = multify.sync;

  App.addInitializer(function(){
    App.layout = new Layout().render();
    multify.initialize();
  });

  multify.on('change:current_user', function(current_user, previousUser){
    var loggedIn = !!current_user;

    if (Backbone.history) Backbone.history.handlers = [];

    if (loggedIn){
      $('#body').addClass('logged-in').removeClass('logged-out');
      App.router = new LoggedInRouter;
      App.multify.get('current_user').projects.fetch();
    }else{
      $('#body').addClass('logged-out').removeClass('logged-in');
      App.router = new LoggedOutRouter;
    }

    if (Backbone.History.started){
      Backbone.history.loadUrl(location.pathname.slice(1));
    }else{
      Backbone.history.start({pushState: true});
    }
  });

  $(function(){
    if(window.location.href.match(/\/spec\??/)) {
      console.log('Would start(), but assuming testing')
    } else {
      App.start({});
    }
  });

  $(document).on('click', 'a[href=""],a[href="#"]', function(event){
    event.preventDefault();
  });

  $(document).on('click', 'a[href]', function(event){
    var href = $(this).attr('href');
    if (href[0] === '/'){
      event.preventDefault();
      App.router.navigate(href, {trigger: true});
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


