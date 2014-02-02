//= require ./conversations_route

Threadable.MutedConversationsRoute = Threadable.ConversationsRoute.extend({

  conversationsScope: 'muted_conversations',

  actions: {
    addConversation: function(conversation) {
      // this.controller.get('model').unshiftObject(conversation);
    }
  }

});
