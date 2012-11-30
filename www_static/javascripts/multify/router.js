Multify.Router = Backbone.Router.extend({

  routes: {
    "":                     "root",
    "users":                "users",
    "user/:user_id":        "user",
    "projects":             "projects",
    "projects/:project_id": "project",
  },

  root: function() {
    console.log('going to root');
  },

  projects: function() {
    console.log('going to projects');
  },

  project: function() {
    console.log('going to project');
  },

  users: function() {
    console.log('going to users');
  },

  user: function() {
    console.log('going to user');
  }

});
