Multify.Task = Backbone.Model.extend({

  initialize: function(attrs, options){
    this.project(options.collection.project);
  },

  id: null,
  project_id: null,
  name: null,
  slug: null,
  created_at: null,
  updated_at: null,

  project: function(project){
    if (project instanceof Backbone.Model){
      this._project = project;
      this.set('project_id', project.id);
    }
    return this._project;
  }
});

Multify.Task.modelName = 'task';
Multify.Task.path = 'tasks';


