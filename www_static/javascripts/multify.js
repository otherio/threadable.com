Multify = {};

Multify.host = 'http://0.0.0.0:3000';

Multify.is_ready = false;
Multify.ready = function(callback){
  if (callback){
    if (this.is_ready){ setTimeout(callback); return this; }
    $(this).bind('ready', callback);
  }else{
    if (this.is_ready) return this;
    this.is_ready = true;
    $(this).trigger('ready');
  }
  return this;
};

Multify.init = function(){

  if (Multify.logged_in && !Multify.current_user){
    Multify.loadCurrentUser().success(function(){ Multify.ready(); });
  }else{
    Multify.ready();
  }

};





Multify.ready(function(){
  console.log('Multify ready');
  if (Multify.logged_in){
    $('body').html('<h1>Welcome back '+Multify.current_user.name+'</h1>');
  }else{
    $('body').html(Multify.View.render('login_form', {email:''}));
  }
});
