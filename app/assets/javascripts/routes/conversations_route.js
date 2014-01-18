// This is a base class. We should never actually endup here
Covered.ConversationsRoute = Ember.Route.extend({

  actions: {
    prependConversation: function(conversation) {
      this.controller.prependConversation(conversation);
    }
  }

});
