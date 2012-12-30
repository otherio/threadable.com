define(function(require) {
  var
    Marionette = require('marionette'),
    multify         = require('multify'),
    template = require('text!templates/logged_out/join.html');

  return Marionette.ItemView.extend({

    // initialize: function(){
    //   this
    //     .on('login:clicked', function(){
    //       multify.login('jared@change.org','password');
    //     })
    //     .on('logout:clicked', function(){
    //       multify.logout();
    //     })
    //   ;
    // },

    template: _.template(template),
    className: 'join',

    // modelEvents: {
    //   "change:current_user": "render"
    // },
    // triggers: {
    //   "submit form":  "login:clicked",
    //   "click a.logout": "logout:clicked"
    // },
    // templateHelpers: {
    //   loggedIn: function(){ return !!this.current_user; }
    // }

    events: {
      "click input[type=submit]": function(e) { this.joinButton(e); }
    },

    joinButton: function(event) {
      event.preventDefault();
      var userInfo = {};
      userInfo.name     = this.$('input[name=name]').val();
      userInfo.email    = this.$('input[name=email]').val();
      userInfo.password = this.$('input[name=password]').val();
      multify.join(userInfo, {
        success: function() { multify.login(userInfo.email, userInfo.password); }
      });
    }
  });
});
