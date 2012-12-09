define(function(require) {

  var
    Backbone = require('backbone'),
    Project  = require('models/Project');

  return Backbone.Collection.extend({
    model: Project,
    path: '/projects'
  });

});

