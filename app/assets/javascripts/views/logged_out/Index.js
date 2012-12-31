define(function(require) {
  var
    Marionette = require('marionette'),
    template = require('text!logged_out/index.html');

  return Marionette.ItemView.extend({
    template: _.template(template),
    className: 'index'
  });
});
