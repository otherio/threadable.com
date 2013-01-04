define(function(require) {
  var
    multify = require('Multify'),
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
      'submit form.new-task': 'createTask',
      'click .done-toggle': 'toggleDone'
    },

    initialize: function() {
      this.collection.on('change', this.render);
      multify.on('change:taskFilter', this.render);
    },

    addItemView: function(item, ItemView, index) {
      if(multify.get('taskFilter') == 'unfinished' && item.get('done')) {
        return;
      }

      Marionette.CollectionView.prototype.addItemView.call(this, item, ItemView, index);
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
    },

    toggleDone: function(e) {
      if($(e.currentTarget).data().show == 'unfinished') {
        multify.set('taskFilter', 'unfinished');
      } else {
        multify.set('taskFilter', null);
      }
    },

    onRender: function() {
      var taskFilter = multify.get('taskFilter');
      if(taskFilter == 'unfinished') {
        this.$el.find('.done-toggle[data-show="unfinished"]').addClass('active');
      } else {
        // the default
        this.$el.find('.done-toggle[data-show="all"]').addClass('active');
      }
    }
  });
});
