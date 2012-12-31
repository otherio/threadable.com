define(function(require) {
  var
    Marionette = require('marionette'),
    tasksTemplate = require('text!logged_in/index/tasks.html'),
    taskTemplate = require('text!logged_in/index/tasks/task.html'),
    emptyTemplate = require('text!logged_in/index/tasks/empty.html');

  var TaskView = Backbone.Marionette.ItemView.extend({
    template: _.template(taskTemplate),
    tagName: 'li',

    initialize: function() {
      this.model.on('change', this.render);
    },

    onRender: function() {
      if(this.model.get('done')) {
        this.$el.addClass('done');
      }
    }
  });

  var EmptyView = Backbone.Marionette.ItemView.extend({
    template: _.template(emptyTemplate),
  });

  return Marionette.CollectionView.extend({
    itemView: TaskView,
    template: _.template(tasksTemplate),
    tagName: 'ul',
    emptyView: EmptyView

  });
});
