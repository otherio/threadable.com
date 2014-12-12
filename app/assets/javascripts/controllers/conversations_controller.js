Threadable.ConversationsController = Ember.ArrayController.extend(Threadable.RoutesMixin, {
  needs: ['organization', 'topbar', 'compose'],
  organization: Ember.computed.alias('controllers.organization').readOnly(),
  newConversation: Ember.computed.alias('controllers.compose').readOnly(),
  itemController: 'conversations_item',
  showingConversationsListControls: Ember.computed.alias('controllers.topbar.showingConversationsListControls'),
  sortAscending: false,

  groupSlug: null,
  conversationsScope: null,
  loading: true,

  PAGE_SIZE: 20, // this should be matched by the server
  currentPage: 0,
  fullyLoaded: false,
  loadFailed: false,
  isTrash: false,

  setup: function(groupSlug, conversationsScope) {
    this.set('model', Ember.ArrayProxy.create({content:[]}));
    this.set('groupSlug', groupSlug);
    this.set('conversationsScope', conversationsScope);
    this.set('currentPage', -1);
    this.set('fullyLoaded', false);
    this.set('loading', false);
    this.loadConversations();

    if(groupSlug == 'trash') {
      this.set('isTrash', true);
      this.set('sortProperties', ['trashedAt']);
    } else {
      this.set('isTrash', false);
      this.set('sortProperties', ['lastMessageAt', 'updatedAt']);
    }
  },

  filteredContent: function() {
    var showTrashed = (this.get('groupSlug') == 'trash');
    var showMuted   = this.get('displayingMutedConversations');

    return this.get('arrangedContent').filter(function(item) {
      if(! showTrashed && item.get('isTrashed')) return false;
      return item.get('muted') ? showMuted : !showMuted;
    });
  }.property('displayingMutedConversations', 'model.@each.isTrashed', 'model.@each.muted', 'model.@each.updatedAt', 'model.@each.lastMessageAt', 'model.@each.trashedAt'),

  displayingConversations: function() {
    return this.get('conversationsScope') == 'not_muted_conversations';
  }.property('conversationsScope'),

  displayingMutedConversations: function() {
    return this.get('conversationsScope') == 'muted_conversations';
  }.property('conversationsScope'),

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

    if (groupSlug !== 'my' && groupSlug !== 'trash' && !organization.get('groups').findBy('slug', groupSlug)){
      this.transitionToRoute('conversations','my');
      return;
    }

    promise = Threadable.Conversation.fetchPageByGroupAndScope(organization, groupSlug, scope, page);

    promise.then(function(conversations) {
      if (conversations.get('length') < self.PAGE_SIZE) self.set('fullyLoaded', true);
      self.set('loading', false);
      self.get('model').pushObjects(conversations.content);
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
