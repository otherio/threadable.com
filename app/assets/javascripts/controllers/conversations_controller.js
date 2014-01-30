Covered.ConversationsController = Ember.ArrayController.extend(Covered.RoutesMixin, {
  needs: ['organization', 'navbar'],
  organization: Ember.computed.alias('controllers.organization').readOnly(),
  itemController: 'conversations_item',
  showingConversationsListControls: Ember.computed.alias('controllers.navbar.showingConversationsListControls'),
  sortProperties: ['updatedAt'],
  sortAscending: false,

  groupSlug: null,
  conversationsScope: null,
  loading: true,

  PAGE_SIZE: 20, // this should be matched by the server
  currentPage: 0,
  fullyLoaded: false,
  loadFailed: false,

  setup: function(groupSlug, conversationsScope) {
    this.set('content', Ember.ArrayProxy.create({content:[]}));
    this.set('groupSlug', groupSlug);
    this.set('conversationsScope', conversationsScope);
    this.set('currentPage', -1);
    this.set('fullyLoaded', false);
    this.set('loading', false);
    this.loadConversations();
  },

  loadConversations: function() {
    if (this.get('loading') || this.get('fullyLoaded')) return;
    var
      self         = this,
      page         = this.get('currentPage') + 1,
      organization = this.get('organization.model'),
      groupSlug    = this.get('groupSlug'),
      scope        = this.get('conversationsScope'),
      promise;

    this.set('loading', true);
    this.set('loadFailed', false);

    promise = Covered.Conversation.fetchPageByGroupAndScope(organization, groupSlug, scope, page);

    promise.then(function(conversations) {
      if (conversations.get('length') < self.PAGE_SIZE) self.set('fullyLoaded', true);
      self.set('loading', false);
      self.get('content').pushObjects(conversations.content);
      self.set('currentPage', page);
    });

    promise.catch(function(response) {
      self.set('loadFailed', true);
      self.set('loading', false);
    });
  },

  actions:{
    loadMore: function() {
      this.loadConversations();
    }
  }
});
