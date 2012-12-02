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



$(function(){



  Multify.router = new Multify.Router;

  Multify.layout = new Multify.Views.Layout;

  Multify.layout.render();

  Backbone.history.start({
    pushState: true,
    root: '/'
  });

});

