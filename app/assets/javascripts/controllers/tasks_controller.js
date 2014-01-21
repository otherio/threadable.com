Covered.TasksController = Ember.ObjectController.extend(Covered.RoutesMixin, {
  needs: ['organization', 'navbar'],
  organization: Ember.computed.alias('controllers.organization').readOnly(),

  notDoneTasks: null,
  doneTasksPromise: null,

  showingDone: false,
  showingConversationsListControls: Ember.computed.alias('controllers.navbar.showingConversationsListControls'),

  actions: {
    showDone: function() {
      this.toggleProperty('showingDone');
    }
  }
});
