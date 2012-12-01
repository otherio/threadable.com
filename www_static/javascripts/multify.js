Multify = {};

Multify.App = Ember.Application.create();

Multify.ApplicationController = Ember.Controller.extend();

Multify.ApplicationView = Ember.View.extend({
  templateName: 'application'
});

Multify.Router = Ember.Router.extend({
  root: Ember.Route.extend({
    index: Ember.Route.extend({
      route: '/'
    })
  })
})



Multify.Project = Ember.Object.extend({
  name: null,
  slug: null,
  description: null
});


projects = [
  Multify.Project.create({name: 'Occupy'}),
  Multify.Project.create({name: 'Eat Food'}),
  Multify.Project.create({name: 'Die HAppy'})
];

Multify.Views = {};

Multify.Views.Project = Ember.View.extend({
  tagName: 'li',
  classNames: ['project'],
  templateName: 'project',
});

// projectController = Ember.Object.create({
//   name: 'wtf pants'
// });

// Multify.Views.Project.create({
//   controller: projectController
// });


Multify.App.initialize();



// // $.extend(Multify, Backbone.Events);

// Multify.host = 'http://0.0.0.0:3000';


// // Multify.App = Ember.Application.create({
// //   Router: Ember.Router.extend({
// //     root: Ember.Route.extend({
// //       index: Ember.Route.extend({
// //         route: '/'
// //       })
// //     })
// //   })
// // });

// var App = Ember.Application.create();

// App.ApplicationController = Ember.Controller.extend();
// App.ApplicationView = Ember.View.extend({
//   templateName: 'application'
// });

// App.Router = Ember.Router.extend({
//   root: Ember.Route.extend({
//     index: Ember.Route.extend({
//       route: '/'
//     })
//   })
// })

// App.initialize();




// // Multify.App.initialize();
// // Multify.App.get('router') // an instance of App.Router

// // Multify.ready = function(callback){
// //   if (callback) return this.on('ready', callback);
// //   this.ready = function(callback){
// //     if (callback) setTimeout(callback);
// //     return this;
// //   }
// //   return this.trigger('ready');
// // };

// // Multify.init = function(){

// //   if (Multify.logged_in){
// //     Multify.trigger('login');
// //   }else{
// //     Multify.trigger('logout');
// //   }

// //   if (Multify.logged_in && !Multify.current_user){
// //     Multify.loadCurrentUser().success(function(){ Multify.ready(); });
// //   }else{
// //     Multify.ready();
// //   }

// // };


// // Multify.ready(function(){
// //   console.log('Multify ready');
// //   View.render_page();
// // });

// // Multify.Models = {};
// // Multify.Collections = {};
// // Multify.Views = {};
