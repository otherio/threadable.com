Covered.ConversationsController = Ember.ArrayController.extend(Covered.RoutesMixin, {
  needs: ['organization', 'navbar'],
  organization: Ember.computed.alias('controllers.organization').readOnly(),
  itemController: 'conversations_item',
  showingConversationsListControls: Ember.computed.alias('controllers.navbar.showingConversationsListControls'),
  sortProperties: ['updatedAt'],
  sortAscending: false,

  groupSlug: null,
  initialLoading: true,

  loadConversations: function(n) {
    var
      self         = this,
      groupSlug    = this.get('groupSlug'),
      organization = this.get('organization.model'),
      scope        = this.get('conversationsScope');
    Covered.Conversation.fetchByGroupAndScope(organization, groupSlug, scope).then(function(conversations) {
      self.set('initialLoading', false);
      self.set('content', conversations);
    });
  }
});
