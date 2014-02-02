Threadable.DoneTasksController = Ember.ArrayController.extend(Threadable.RoutesMixin, {
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
  loadFailed: false,

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
      scope        = this.get('tasksScope'),
      promise;

    this.set('loading', true);
    this.set('loadFailed', false);

    promise = Threadable.Conversation.fetchPageByGroupAndScope(organization, groupSlug, scope, page);

    promise.then(function(tasks) {
      if (tasks.get('length') < self.PAGE_SIZE) self.set('fullyLoaded', true);
      self.set('loading', false);
      self.set('currentPage', page);
      self.get('content').pushObjects(tasks.content);
    });

    promise.catch(function(response) {
      self.set('loadFailed', true);
      self.set('loading', false);
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
