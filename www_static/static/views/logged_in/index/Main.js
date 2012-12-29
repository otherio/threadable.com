define(function(require) {
  var
    Marionette   = require('marionette'),
    Backbone     = require('backbone'),
    TasksView        = require('views/logged_in/index/Tasks'),
    MembersView      = require('views/logged_in/index/Members'),
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
      'tasks': function() {
        // TODO: this should happen:
        // make sure to require tasks
        // var tasks = new Tasks({project: model.id});
        // tasks.fetch();
        // return new TasksView({collection: tasks});
        return new TasksView();
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
      this.tabContent.show(this.tabViews[tab]());
      this.$('> .tabs > li').removeClass('active');
      this.$('> .tabs > li.'+tab).addClass('active');
      Backbone.history.navigate($(e.target).attr('href'));
    }
  });
});
