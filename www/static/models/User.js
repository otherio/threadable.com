define(function(require) {

  var
    Backbone = require('backbone'),
    Projects = require('models/Projects');

  return Backbone.Model.extend({
    path: '/users',
    modelName: 'user',

    initialize: function(params, options) {
      this.projects = new Projects;
      this.feed = new Backbone.Collection;

      if(options && options.path) {
        this.path = options.path;
      }
    }
  });

});

