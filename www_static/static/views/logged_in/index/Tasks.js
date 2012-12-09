define(function(require) {
  var
    Marionette = require('marionette'),
    tasksTemplate = require('text!templates/logged_in/index/tasks.html'),
    taskTemplte = require('text!templates/logged_in/index/tasks/task.html'),
    emptyTemplte = require('text!templates/logged_in/index/tasks/empty.html');

  var task = Backbone.Marionette.ItemView.extend({
    template: _.template(taskTemplte),
    tagName: 'li'
  });

  var Empty = Backbone.Marionette.ItemView.extend({
    template: _.template(emptyTemplte),
  });

  return Marionette.CollectionView.extend({
    itemView: task,
    // template: _.template(tasksTemplate),
    tagName: 'ol',
    emptyView: Empty

  });
});
