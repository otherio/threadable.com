define(function(require) {

  var
    Backbone = require('backbone'),
    Task  = require('models/Task');

  return Backbone.Collection.extend({
    model: Task,
    path: '/tasks',

    initialize: function(models, options) {
      if(options && options.project) {
        this.path = '/projects/' + options.project.id + this.path;
      }
    },

    findBySlug: function(slug){
      return this.find(function(task){
        return task.get('slug') === slug;
      });
    }

  });

});

