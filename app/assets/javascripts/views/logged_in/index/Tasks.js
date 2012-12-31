define(function(require) {
  var
    Marionette = require('marionette'),
    Task = require('models/Task'),
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
    tagName: 'li'
  });

  return Marionette.CompositeView.extend({
    itemView: TaskView,
    template: _.template(tasksTemplate),
    itemViewContainer: 'ul',
    emptyView: EmptyView,

    events: {
      'submit form.new-task': 'createTask'
    },

    createTask: function(e) {
      e.preventDefault();
      var
        element = $(e.currentTarget).find('input'),
        taskName = element.val();

      if(! taskName) { return; }
      var task = new Task({name: taskName, project_id: this.model.id});
      this.collection.add(task);
      task.save();
      element.val('');
    }
  });
});
