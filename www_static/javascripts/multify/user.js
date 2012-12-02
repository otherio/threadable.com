Multify.User = Backbone.Model.extend({

  id: null,
  name: null,
  email: null,
  slug: null,
  created_at: null,
  updated_at: null,

  initialize: function() {
    this.projects = new Multify.Projects;
    this.projects.user = this;
  }
});

Multify.User.modelName = 'user';
Multify.User.path = 'users';


