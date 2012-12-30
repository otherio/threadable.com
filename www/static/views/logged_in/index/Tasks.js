define(function(require) {
  var
    Marionette = require('marionette'),
    tasksTemplate = require('text!templates/logged_in/index/tasks.html'),
    taskTemplate = require('text!templates/logged_in/index/tasks/task.html'),
    emptyTemplate = require('text!templates/logged_in/index/tasks/empty.html');

  var TaskView = Backbone.Marionette.ItemView.extend({
    template: _.template(taskTemplate),
    tagName: 'li'
  });

  var EmptyView = Backbone.Marionette.ItemView.extend({
    template: _.template(emptyTemplate),
  });

  return Marionette.CollectionView.extend({
    itemView: TaskView,
    template: _.template(tasksTemplate),
    tagName: 'ol',
    emptyView: EmptyView

  });
});
