define(function(require) {
  var
    Marionette = require('marionette'),
    Task = require('models/Task'),
    tasksTemplate = require('text!logged_in/index/tasks.html'),
    taskTemplate = require('text!logged_in/index/tasks/task.html'),
    emptyTemplate = require('text!logged_in/index/tasks/empty.html');

  var TaskView = Backbone.Marionette.ItemView.extend({
    template: _.template(taskTemplate),
    tagName: 'tr',

    initialize: function() {
      this.model.on('change', this.render);
    },

    events: {
      'click td.task-status': 'onClickDone'
    },

    onRender: function() {
      if(this.model.get('done')) {
        this.$el.addClass('done');
      }
    },

    onClickDone: function(e) {
      this.model.set('done', 1);
      this.model.save();
    }
  });

  var EmptyView = Backbone.Marionette.ItemView.extend({
    template: _.template(emptyTemplate),
    tagName: 'tr'
  });

  return Marionette.CompositeView.extend({
    itemView: TaskView,
    template: _.template(tasksTemplate),
    itemViewContainer: 'tbody',
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
