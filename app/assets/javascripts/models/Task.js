define(function(require) {

  var Backbone = require('backbone');

  return Backbone.Model.extend({
    path: '/tasks',
    modelName: 'task'
  });

});
