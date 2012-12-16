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
    className: 'join'

    // modelEvents: {
    //   "change:current_user": "render"
    // },

    // triggers: {
    //   "click a.login":  "login:clicked",
    //   "click a.logout": "logout:clicked"
    // },

    // templateHelpers: {
    //   loggedIn: function(){ return !!this.current_user; }
    // }

  });
});
