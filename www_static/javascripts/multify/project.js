Multify.Project = Backbone.Model.extend({
  name: null,
  slug: null,

  initialize: function() {
    this.tasks = new Multify.Tasks;
    this.tasks.project = this;
  }
});

Multify.Project.modelName = 'project';
Multify.Project.path = 'projects';
