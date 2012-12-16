Multify.User = Backbone.Model.extend({

  id: null,
  name: null,
  email: null,
  slug: null,
  created_at: null,
  updated_at: null,

  initialize: function() {
    this.projects = new Multify.Projects;
  }
});

Multify.User.modelName = 'user';
Multify.User.path = 'users';


