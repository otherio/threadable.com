define(function(require) {
  var
    Marionette   = require('marionette'),
    Backbone     = require('backbone'),
    TasksView    = require('views/logged_in/index/Tasks'),
    Tasks        = require('models/Tasks'),
    MembersView  = require('views/logged_in/index/Members'),
    template     = require('text!logged_in/index/main.html');

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
      'tasks': function() {
        var tasks = new Tasks([], {project: this.model});
        tasks.fetch();
        return new TasksView({model: this.model, collection: tasks});
      },

      'members': function() {
        return new MembersView();
      }
    },

    onRender: function(){
      this.$('> .tabs > li.tasks > a').click();
    },

    setActiveTab: function(e) {
      e.preventDefault();
      e.stopPropagation();
      var tab = $(e.target).attr('name');
      this.tabContent.show(_.bind(this.tabViews[tab], this)());
      this.$('> .tabs > li').removeClass('active');
      this.$('> .tabs > li.'+tab).addClass('active');
      Backbone.history.navigate($(e.target).attr('href'));
    }
  });
});
