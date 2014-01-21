Covered.TasksController = Ember.ObjectController.extend(Covered.RoutesMixin, {
  needs: ['organization'],
  organization: Ember.computed.alias('controllers.organization').readOnly(),

  notDoneTasks: null,
  doneTasksPromise: null,

  showingDone: false,

  actions: {
    showDone: function() {
      this.toggleProperty('showingDone');
    }
  }
});
