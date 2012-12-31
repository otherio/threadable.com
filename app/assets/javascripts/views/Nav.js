define(function(require) {
  var
    Marionette = require('marionette'),
    User = require('models/User'),
    template = require('text!nav.html'),
    multify  = require('Multify');

  return Marionette.ItemView.extend({
    template: _.template(template),

    initialize: function(){
      multify.on('change:current_user', _.bind(this.render, this));
    },

    templateHelpers: function() {
      return {
        loggedIn: !!multify.get('current_user'),
        current_user: multify.get('current_user')
      };
    },

    events: {
      'click .login-submit':  function(e) {
        e.preventDefault();
        multify.login(this.$('form.login input[name=email]').val(), this.$('form.login input[name=password]').val());
      },
      'click .logout': function(e) {
        multify.logout();
      }
    }
  });
});
