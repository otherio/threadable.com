define(function(require) {

  var
    Marionette = require('marionette'),
    Multify         = require('multify'),
    template = require('text!templates/logged_out/join.html');

  return Marionette.ItemView.extend({

    // initialize: function(){
    //   this
    //     .on('login:clicked', function(){
    //       Multify.login('jared@change.org','password');
    //     })
    //     .on('logout:clicked', function(){
    //       Multify.logout();
    //     })
    //   ;
    // },

    template: _.template(template),
    className: 'join'

    // modelEvents: {
    //   "change:currentUser": "render"
    // },

    // triggers: {
    //   "click a.login":  "login:clicked",
    //   "click a.logout": "logout:clicked"
    // },

    // templateHelpers: {
    //   loggedIn: function(){ return !!this.currentUser; }
    // }

  });
});
