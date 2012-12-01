Multify.Router = Backbone.Router.extend({

  routes: {
    "":             "home",
    "projects/:project_id": "project"
  },

  home: function() {
    console.log('HOME ROUTE', this, arguments);
  },

  project: function(query, page) {
    console.log('PROJECT ROUTE', this, arguments);
  }

});
