Multify = {};

$.extend(Multify, Backbone.Events);

Multify.host = 'http://0.0.0.0:3000';

Multify.ready = function(callback){
  if (callback) return this.on('ready', callback);
  this.ready = function(callback){
    if (callback) setTimeout(callback);
    return this;
  }
  return this.trigger('ready');
};

Multify.init = function(){

  if (Multify.logged_in){
    Multify.trigger('login');
  }else{
    Multify.trigger('logout');
  }

  if (Multify.logged_in && !Multify.current_user){
    Multify.loadCurrentUser().success(function(){ Multify.ready(); });
  }else{
    Multify.ready();
  }

};


Multify.ready(function(){
  console.log('Multify ready');
  View.render_page();
});

Multify.Models = {};
Multify.Collections = {};
Multify.Views = {};
