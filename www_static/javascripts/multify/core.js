Multify = {

  current_user: null,
  logged_in: null,


  get: function(attr) {
    return this.attributes[attr];
  },

  set: function(attr, value){
    var current_value = self[attr];
    if (value !== current_value){
      self[attr] = value;
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

  Multify.layout.render();

  Backbone.history.start({
    pushState: true,
    root: '/'
  });

});


Multify.on('change:current_user', function(){
  console.log('CURRENT USER CHANGES', this, arguments);
});

// Multify.set('current_user', 1)
// Multify.set('current_user', 1)
// Multify.set('current_user', 1)
