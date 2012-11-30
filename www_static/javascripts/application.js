//= require "s"
//= require "jquery"
//= require "jquery-s"
//= require "jquery-cookie"
//= require "underscore"
//= require "backbone"
//= require "multify"
//= require "models/user"
//= require "multify/session"
//= require "multify/authentication"
//= require "multify/router"



$(function(){

  Multify.router = new Multify.Router;

  Backbone.history.start({
    pushState: true,
    root: '/'
  });

});





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
