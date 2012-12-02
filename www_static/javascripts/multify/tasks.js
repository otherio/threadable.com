Multify.Tasks = Backbone.Collection.extend({

  model: Multify.Task,

  path: 'tasks',

  initialize: function(project){
    this.project = project;
  }

});


Multify.Tasks.path = 'tasks';
