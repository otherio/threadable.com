Multify = {

  current_user: null,
  logged_in: null,

  get: function(attr) {
    return this.attributes[attr];
  },

  set: function(attr, value){
    var current_value = self[attr];
    if (value !== current_value){
      this[attr] = value;
      this.trigger('change:'+attr, value, current_value);
    }
    return value;
  },

  Views: {},

  host: 'http://0.0.0.0:3000'

};

$.extend(Multify, Backbone.Events);


$(function(){

  Multify.router = new Multify.Router;
  Multify.layout = new Multify.Views.Layout;

  Multify.on('change:logged_in', function(){
    Multify.layout.render();
  });

  if (Multify.session.authentication_token){
    Multify.set('current_user', new Multify.User(Multify.session.user));
    Multify.set('logged_in', true);
  }else{
    Multify.set('current_user', null);
    Multify.set('logged_in', false);
  }

  Backbone.history.start({
    pushState: true,
    root: '/'
  });

});




// Multify.set('current_user', 1)
// Multify.set('current_user', 1)
// Multify.set('current_user', 1)
