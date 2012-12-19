define(function(require) {

  var
    Backbone = require('backbone'),
    Projects = require('models/Projects');

  return Backbone.Model.extend({
    path: '/users',
    modelName: 'user',

    initialize: function() {
      this.projects = new Projects;
      this.feed = new Backbone.Collection;
    }
  });

});

