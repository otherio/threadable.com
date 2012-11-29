//= require "uri"
//= require "jquery"
//= require "jquery-cookie"
//= require "mustache"
//= require "multify"
//= require "multify/session"
//= require "multify/authentication"
//= require "multify/view"
//= require "multify/view/template"



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
