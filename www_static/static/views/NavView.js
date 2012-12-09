define(function(require) {

  var
    Marionette = require('marionette'),
    template = require('text!templates/nav.html');

  return Marionette.ItemView.extend({
    template: _.template(template),

    modelEvents: {
      "change:currentUser": "render"
    },

    triggers: {
      "click a.login":  "login:clicked",
      "click a.logout": "logout:clicked"
    }

  });
});
