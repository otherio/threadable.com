Covered.DoneTasksController = Ember.ArrayController.extend(Covered.RoutesMixin, {
  needs: ['organization', 'tasks'],
  organization: Ember.computed.alias('controllers.organization').readOnly(),
  itemController: 'tasks_item',

  visible: Ember.computed.alias('controllers.tasks.showingDone'),

  content: [],
  // sortProperties: ['position'],
  // sortAscending: true,

  groupSlug: null,
  tasksScope: null,
  initialLoading: true,

  loadTasks: function() {
    if (!this.get('visible')) return;
    var
      self = this,
      organization = this.get('organization.model'),
      groupSlug = this.get('groupSlug'),
      scope = this.get('tasksScope');
    Covered.Conversation.fetchByGroupAndScope(organization, groupSlug, scope).then(function(tasks) {
      self.set('initialLoading', false);
      self.set('content', tasks);
    });
  },

  visibleChanged: function() {
    this.loadTasks();
  }.observes('visible').on('init')

});
