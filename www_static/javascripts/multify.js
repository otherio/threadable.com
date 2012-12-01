Multify = {};

_.extend(Multify, Backbone.Events);

Multify.templates = {};
Multify.Template = function(name, value){
  Multify.templates[name] = _.template(value);
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


Multify.Views = {};

Multify.Views.Layout = Backbone.View.extend({
  initialize: function(){
    this.render();
  },

  render: function(){
    var html = Multify.templates.layout({projects:TEMP_FAKE_PROJECTS});
    this.$el.html(html);
  }
});

$(function(){

  Multify.layout = new Multify.Views.Layout({el: $('body')});

  Multify.router = new Multify.Router;
  Backbone.history.start({
    pushState: true,
    root: '/'
  });
});
