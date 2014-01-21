Covered.ConversationsRoute = Ember.Route.extend({

  model: function(params) {
    var
      groupSlug = this.modelFor('group'),
      organization = this.modelFor('organization');
    return Covered.Conversation.fetchByGroupAndScope(organization, groupSlug, 'not_muted_conversations');
  },

  renderTemplate: function() {
    this.render('conversations', {into: 'organization', outlet: 'conversationsPane'});
  },


  actions: {
    addConversation: function(conversation) {
      this.controller.get('model').unshiftObject(conversation);
    }
  }

});
