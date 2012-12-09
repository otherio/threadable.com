define(function(require) {
  var
    Marionette = require('marionette'),
    User = require('models/User'),
    template = require('text!templates/nav.html');

  return Marionette.ItemView.extend({
    template: _.template(template),

    modelEvents: {
      "change": "render"
    },

    triggers: {
      "click a.login": "login:clicked"
    }

    // templateHelpers: function() {
    //   return this.options;
    // },

    // onRender: function(){

    // }


  });
});
