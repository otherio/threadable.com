define(function(require) {
  var
    Marionette = require('marionette'),
    template = require('text!templates/logged_in/index/project.html');

  return Marionette.ItemView.extend({
    template: _.template(template)
  });

});
