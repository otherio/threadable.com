Multify = {};
// Multify = Backbone.Model.extend({
//   host: null,
//   current_user_id: null,
//   current_user: null,
//   logged_in: null,
// });

Multify.Views = {};

_.extend(Multify, Backbone.Events);


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

  if (Multify.logged_in && !Multify.current_user){
    Multify.loadCurrentUser().success(function(){ Multify.ready(); });
  }else{
    Multify.ready();
  }

};



$(function(){
  Multify.init();
});

Multify.ready(function(){

  Multify.router = new Multify.Router;
  Backbone.history.start({
    pushState: true,
    root: '/'
  });




  Multify.layout = new Multify.Views.Layout;

  Multify.layout.render();


});

