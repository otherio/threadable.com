define(function(require) {
  var
    Marionette = require('marionette'),
    User = require('models/User'),
    template = require('text!templates/nav.html'),
    multify  = require('multify');

  return Marionette.ItemView.extend({
    template: _.template(template),

    initialize: function(){
      multify.on('change:current_user', this.render.bind(this));
    },

    templateHelpers: function() {
      return {
        loggedIn: !!multify.get('current_user'),
        current_user: multify.get('current_user')
      };
    },

    events: {
      'click .login':  function(e) {
        multify.login('jared@change.org', 'password');
      },
      'click .logout': function(e) {
        multify.logout();
      }
    }

  });
});
