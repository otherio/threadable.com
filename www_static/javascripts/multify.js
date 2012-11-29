Multify = {};

Multify.host = 'http://0.0.0.0:3000';



Multify.init = function(){


};





$(function(){
  if (Multify.logged_in){
    Multify.user=  { name: 'fix me'}
    $('body').html('<h1>Welcome back '+Multify.user.name+'</h1>');
  }else{
    $('body').html(Multify.View.render('login_form', {email:''}));
  }
});
