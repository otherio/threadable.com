define(function(require) {

  var Backbone = require('backbone');

  return Backbone.Model.extend({

    path: '/users',
    model_name: 'user',

    id: null,
    name: null,
    email: null,
    slug: null,
    created_at: null,
    updated_at: null,

    initialize: function() {
      // this.projects = new Projects;
    }
  });

});

