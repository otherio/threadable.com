Covered.ConversationsRoute = Ember.Route.extend({

  conversationsScope: 'not_muted_conversations',

  setupController: function(controller, context, transition) {
    controller = this.controllerFor('conversations');
    controller.set('groupSlug', this.modelFor('group'));
    controller.set('conversationsScope', this.conversationsScope);
    controller.set('initialLoading', true);
    controller.loadConversations();
    this.controllerFor('navbar').set('showingConversationsListControls', false);
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
