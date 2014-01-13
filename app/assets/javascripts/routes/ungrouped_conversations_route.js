Covered.UngroupedConversationsRoute = Covered.ConversationsRoute.extend({

  model: function() {
    return Covered.Conversation.fetch({
      organization_id: this.modelFor('organization').get('slug'),
      ungrouped: true
    });
  },

  setupController: function(controller, model) {
    this._super(controller, model);
    this.controllerFor('navbar').set('group', null);
    this.controllerFor('organization').set('composeTarget', 'ungrouped');
  },

  renderTemplate: function() {
    this.render('ungrouped_conversations', {into: 'organization', outlet: 'conversationsPane'});
  }

});
