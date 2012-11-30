//= require "uri"
//= require "s"
//= require "jquery"
//= require "jquery-s"
//= require "jquery-cookie"
//= require "mustache"
//= require "events"
//= require "view"
//= require "view/template"
//= require "component"
//= require "multify"
//= require "multify/session"
//= require "multify/authentication"

//= require_tree "./components"



setTimeout(function(){
  Multify.init();
});


$(document).on('submit', '.login_form', function(event){
  event.preventDefault();
  var form = $(this),
    email = form.find('input[name=email]').val(),
    password = form.find('input[name=password]').val();
  Multify.login(email, password);
})
