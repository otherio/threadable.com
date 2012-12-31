define(function(require) {
  var
    Marionette = require('marionette'),
    User = require('models/User'),
    template = require('text!splash.html');

  return Marionette.ItemView.extend({
    template: _.template(template),
    className: 'nav'

  });
});
