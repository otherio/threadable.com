Multify.Router = Backbone.Router.extend({

  routes: {
    "":             "home",
    "projects/:project_id": "project"
  },

  home: function() {
    console.log('HOME ROUTE', this, arguments);
  },

  project: function(query, page) {
    if (!Multify.logged_in){
      this.navigate('/', {trigger: true});
      return;
    }
    console.log('PROJECT ROUTE', this, arguments);
  }

});
