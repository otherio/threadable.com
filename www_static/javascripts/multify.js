Multify = {};

_.extend(Multify, Backbone.Events);

Multify.views = {};
Multify.View = function(name, value){
  Multify.views[name] = _.template(value);
};


Multify.Router = Backbone.Router.extend({

  routes: {
    "":             "home",
    "projects/:project_id": "project"
  },

  home: function() {
    console.log('HOME ROUTE', this, arguments);
  },

  project: function(query, page) {
    console.log('PROJECT ROUTE', this, arguments);
  }

});


TEMP_FAKE_PROJECTS = [
  {name:'love steve'},
  {name:'eat sally'},
  {name:'pickup mustard'}
];

$(function(){
  $('body').html(Multify.views.application({projects:TEMP_FAKE_PROJECTS}));

  Multify.router = new Multify.Router;
  Backbone.history.start({
    pushState: true,
    root: '/'
  });
});
