// This is a base class. We should never actually endup here
Covered.ConversationsRoute = Ember.Route.extend({

  mode: 'conversations-mode', // conversations-mode | tasks-mode | muted-mode

  modelFetchOptions: function() {
    return {};
  },

  model: function() {
    var organization = this.modelFor('organization');
    return Covered.Conversation.fetch(this.modelFetchOptions()).then(function(conversations) {
      conversations.forEach(function(conversation){
        conversation.set('organization', organization);
      });
      return conversations;
    });
  },

  actions: {
    prependConversation: function(conversation) {
      this.modelFor(this.routeName).unshiftObject(conversation);
    }
  }

});
