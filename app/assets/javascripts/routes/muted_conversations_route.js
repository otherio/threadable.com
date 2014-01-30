//= require ./conversations_route

Covered.MutedConversationsRoute = Covered.ConversationsRoute.extend({

  conversationsScope: 'muted_conversations',

  actions: {
    addConversation: function(conversation) {
      // this.controller.get('model').unshiftObject(conversation);
    }
  }

});
