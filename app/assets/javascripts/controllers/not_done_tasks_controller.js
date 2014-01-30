Covered.NotDoneTasksController = Ember.ArrayController.extend(Covered.RoutesMixin, {
  needs: ['organization'],
  organization: Ember.computed.alias('controllers.organization').readOnly(),
  itemController: 'not_done_tasks_item',

  content: [],
  sortProperties: ['position'],
  sortAscending: true,

  groupSlug: null,
  tasksScope: null,
  initialLoading: true,

  loadTasks: function() {
    var
      self = this,
      organization = this.get('organization.model'),
      groupSlug = this.get('groupSlug'),
      scope = this.get('tasksScope');
    Covered.Conversation.fetchByGroupAndScope(organization, groupSlug, scope).then(function(tasks) {
      self.set('initialLoading', false);
      self.set('content', tasks);
    });
  }

});
