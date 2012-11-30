//= require "s"
//= require "jquery"
//= require "jquery-s"
//= require "jquery-cookie"
//= require "handlebars"
//= require "ember"
//= require "multify"
//= require "multify/session"
//= require "multify/authentication"


var App = Ember.Application.create();

App.ApplicationController = Ember.Controller.extend();
App.ApplicationView = Ember.View.extend({
  templateName: 'application'
});

App.Router = Ember.Router.extend({
  root: Ember.Route.extend({
    index: Ember.Route.extend({
      route: '/'
    })
  })
})

App.initialize();


// $(function(){

//   Multify.router = new Multify.Router;

//   Backbone.history.start({
//     pushState: true,
//     root: '/'
//   });

// });





// //= require "uri"
// //= require "s"
// //= require "jquery"
// //= require "jquery-s"
// //= require "jquery-cookie"
// //= require "mustache"
// //= require "events"
// //= require "view"
// //= require "view/template"
// //= require "component"
// //= require "multify"
// //= require "multify/session"
// //= require "multify/authentication"

// //= require "layout"
// //= require_tree "./components"



// setTimeout(function(){
//   Multify.init();
// });
