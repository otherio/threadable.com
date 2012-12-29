define(function(require) {
  var
    Marionette   = require('marionette'),
    Backbone     = require('backbone'),
    Tasks        = require('views/logged_in/index/Tasks'),
    Members      = require('views/logged_in/index/Members'),
    template     = require('text!templates/logged_in/index/main.html');

  return Marionette.Layout.extend({
    template: _.template(template),

    className: 'main',

    regions:{
      'tabs': '.tabs',
      'tabContent': '.tabContent'
    },

    events: {
      'click .tabs': function(e) { this.setActiveTab(e); }
    },

    tabViews: {
      'tasks': Tasks,
      'members': Members
    },

    onRender: function(){
      this.$('> .tabs > li.tasks > a').click();
    },

    setActiveTab: function(e) {
      e.preventDefault();
      e.stopPropagation();
      var tab = $(e.target).attr('name');
      this.tabContent.show(new this.tabViews[tab]({model: this.model}));
      this.$('> .tabs > li').removeClass('active');
      this.$('> .tabs > li.'+tab).addClass('active');
      Backbone.history.navigate($(e.target).attr('href'));
    }
  });
});
