Covered.TasksRoute = Ember.Route.extend({

  doneTasksScope: 'done_tasks',
  notDoneTasksScope: 'not_done_tasks',

  organization: function() { return this.modelFor('organization'); },
  groupSlug:    function() { return this.modelFor('group'); },

  setupController: function(controller, context, transition) {
    this.controllerFor('doneTasks').setProperties({
      groupSlug:      this.modelFor('group'),
      tasksScope:     this.doneTasksScope,
      initialLoading: true
    }).loadTasks();

    this.controllerFor('notDoneTasks').setProperties({
      groupSlug:      this.modelFor('group'),
      tasksScope:     this.notDoneTasksScope,
      initialLoading: true
    }).loadTasks();

    this.controllerFor('navbar').set('showingConversationsListControls', false);
  },

  renderTemplate: function() {
    this.render('tasks', {into: 'organization', outlet: 'conversationsPane'});
  },

  actions: {
    addConversation: function(conversation) {
      // this.controller.get('model').unshiftObject(conversation);
    },
    refresh: function(callback) {
      var notDoneTasks = this.controllerFor('notDoneTasks');

      this.notDoneTasks().then(function(newTasks) {
        notDoneTasks.set('model', newTasks);
      });
    }
  }

});
