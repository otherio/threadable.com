Threadable.ConversationsRoute = Ember.Route.extend({

  conversationsScope: 'not_muted_conversations',

  setupController: function(controller, context, transition) {
    this.controllerFor('conversations').setup(this.modelFor('group'), this.conversationsScope);
    this.controllerFor('topbar').set('showingConversationsListControls', false);
  },

  renderTemplate: function() {
    this.render('conversations', {into: 'organization', outlet: 'pane1'});
  },

  actions: {
    addConversation: function(conversation) {
      this.controller.get('model').unshiftObject(conversation);
    }
  }

});
