Covered.TasksRoute = Ember.Route.extend({

  doneTasksScope: 'done_tasks',
  notDoneTasksScope: 'not_done_tasks',

  organization: function() { return this.modelFor('organization'); },
  groupSlug:    function() { return this.modelFor('group'); },

  setupController: function(controller, context, transition) {
    this.controllerFor('doneTasks').setup(this.modelFor('group'), this.doneTasksScope);
    this.controllerFor('notDoneTasks').setup(this.modelFor('group'), this.notDoneTasksScope);
    this.controllerFor('topbar').set('showingConversationsListControls', false);
  },

  renderTemplate: function() {
    this.render('tasks', {into: 'organization', outlet: 'pane1'});
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
