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
  loading: true,

  PAGE_SIZE: 20, // this should be matched by the server
  currentPage: 0,
  fullyLoaded: false,

  setup: function(groupSlug, tasksScope) {
    this.set('content', Ember.ArrayProxy.create({content:[]}));
    this.set('groupSlug', groupSlug);
    this.set('tasksScope', tasksScope);
    this.set('currentPage', -1);
    this.set('fullyLoaded', false);
    this.set('loading', false);
    this.loadTasks();
  },

  loadTasks: function() {
    if (!this.get('visible') || this.get('loading') || this.get('fullyLoaded')) return;

    var
      self         = this,
      page         = this.get('currentPage') + 1,
      organization = this.get('organization.model'),
      groupSlug    = this.get('groupSlug'),
      scope        = this.get('tasksScope');

    Covered.Conversation.fetchPageByGroupAndScope(organization, groupSlug, scope, page).then(function(tasks) {
      if (tasks.get('length') < self.PAGE_SIZE) self.set('fullyLoaded', true);
      self.set('loading', false);
      self.set('currentPage', page);
      self.get('content').pushObjects(tasks.content);
      console.log('new done tasks', tasks.content);
    });
  },

  visibleChanged: function() {
    this.loadTasks();
  }.observes('visible').on('init'),


  actions: {
    loadMore: function() {
      this.loadTasks();
    }
  }

});
