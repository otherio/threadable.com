define(function(require) {
  var
    Marionette = require('marionette'),
    User = require('models/User'),
    template = require('text!templates/nav.html');

  return Marionette.Layout.extend({
    template: _.template(template),


  });
});

