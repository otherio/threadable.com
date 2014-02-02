Threadable.TasksController = Ember.ObjectController.extend(Threadable.RoutesMixin, {
  needs: ['organization', 'topbar'],
  organization: Ember.computed.alias('controllers.organization').readOnly(),

  notDoneTasks: null,
  doneTasksPromise: null,

  showingDone: false,
  prioritizing: false,
  showingConversationsListControls: Ember.computed.alias('controllers.topbar.showingConversationsListControls'),

  actions: {
    toggleDone: function() {
      this.toggleProperty('showingDone');
    },
    togglePrioritizing: function() {
      this.toggleProperty('prioritizing');
    }
  }
});
