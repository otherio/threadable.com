Covered.ConversationsRoute = Ember.Route.extend({

  conversationsScope: 'not_muted_conversations',

  setupController: function(controller, context, transition) {
    this.controllerFor('conversations').setup(this.modelFor('group'), this.conversationsScope);
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
