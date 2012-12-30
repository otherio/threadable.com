define(function(require) {

  var
    Backbone = require('backbone'),
    Project  = require('models/Project');

  return Backbone.Collection.extend({
    model: Project,
    path: '/projects',

    findBySlug: function(slug){
      return this.find(function(project){
        return project.get('slug') === slug;
      });
    }

  });

});

