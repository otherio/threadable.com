Threadable.ConversationsRoute = Ember.Route.extend({

  conversationsScope: 'not_muted_conversations',

  setupController: function(controller, context, transition) {
    this.controllerFor('conversations').setup(this.modelFor('group'), this.conversationsScope);
    this.controllerFor('topbar').set('showingConversationsListControls', false);

    this.modelFor('application').on('create-conversation', this, this.addOrUpdateConversation);
    this.modelFor('application').on('update-conversation', this, this.addOrUpdateConversation);
  },

  renderTemplate: function() {
    this.render('conversations', {into: 'organization', outlet: 'pane1'});
  },

  addOrUpdateConversation: function(update) {
    var organization = this.modelFor('organization');
    if(organization.get('id') !== update.get('organizationId')) {
      return; // some other org.
    }

    var conversationObject = update.get('payload').conversation;
    var conversations = this.controller.get('model');
    var existingConversation = conversations.findBy('id', conversationObject.id);

    if(existingConversation) {
      existingConversation.setProperties(conversationObject);
    } else {
      var newConversation = Threadable.Conversation.create(conversationObject);
      newConversation.set('organization', organization);
      conversations.unshiftObject(newConversation);
    }
  },

  willTransition: function() {
    this.modelFor('application').off('create-conversation', this.addOrUpdateConversation);
    this.modelFor('application').off('update-conversation', this.addOrUpdateConversation);
  },

  actions: {
    addConversation: function(conversation) {
      this.controller.get('model').unshiftObject(conversation);
    }
  }

});
