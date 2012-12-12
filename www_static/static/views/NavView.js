define(function(require) {
  var
    Marionette = require('marionette'),
    User = require('models/User'),
    template = require('text!templates/nav.html'),
    Multify  = require('multify');

  return Marionette.ItemView.extend({
    template: _.template(template),

    templateHelpers: function() {
      return {
        loggedIn: !!Multify.get('current_user'),
        current_user: Multify.get('current_user')
      };
    },

    events: {
      'click .login': function(e) { this.login(e) }
    },

    login: function(e) {
      e.preventDefault();
      e.stopPropagation();
      Multify.login('jared@change.org', 'password');
    }
  });
});
