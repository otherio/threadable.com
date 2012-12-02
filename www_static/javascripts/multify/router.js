Multify.Router = Backbone.Router.extend({

  routes: {
    "":                           "home",
    "projects/:project_id":       "project",
    "projects/:project_id/:tab":  "project"
  },

  home: function() {
    console.log('HOME ROUTE', this, arguments);
  },

  project: function(query, page) {
    if (!Multify.logged_in){
      this.navigate('/', {trigger: true});
      return false;
    }
    console.log('PROJECT ROUTE', this, arguments);
  },

  project_tasks: function(query, page) {

  }

});
