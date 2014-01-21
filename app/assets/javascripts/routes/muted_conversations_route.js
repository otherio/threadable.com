Covered.MutedConversationsRoute = Covered.ConversationsRoute.extend({

  model: function(params) {
    var
      groupSlug = this.modelFor('group'),
      organization = this.modelFor('organization');

    return Covered.Conversation.fetchByGroupAndScope(organization, groupSlug, 'muted_conversations');
  },

  actions: {
    addConversation: function(conversation) {
      // this.controller.get('model').unshiftObject(conversation);
    }
  }

});
