// This is a base class. We should never actually endup here
Covered.ConversationsRoute = Ember.Route.extend({

  modelFetchOptions: function() {
    return {};
  },

  model: function() {
    var organization = this.modelFor('organization');
    var conversations = Covered.Conversation.fetch(this.modelFetchOptions());
    return conversations.then(function(conversations) {
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
