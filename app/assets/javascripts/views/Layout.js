// TODO rename this to page
define(function(require) {

  var
    Marionette = require('marionette'),
    template   = require('text!layout.html'),
    Nav        = require('views/Nav');

  return Marionette.Layout.extend({

    el: '#body',

    template: _.template(template),

    className: 'layout',

    regions:{
      nav: ".nav",
      main: ".main"
    },

    onRender: function(){
      this.nav.show(new Nav({model: App.multify}));
    }

  });

});
