Covered.UngroupedConversationsRoute = Ember.Route.extend({

  model: function() {
    return Covered.Conversation.fetch({
      organization_id: this.modelFor('organization').get('slug'),
      ungrouped: true
    });
  },

  setupController: function(controller, model) {
    this._super(controller, model);
    this.controllerFor('navbar').setProperties({
      group: null,
      composeTarget: 'ungrouped'
    });
  },

  renderTemplate: function() {
    this.render('ungrouped_conversations', {into: 'organization', outlet: 'conversationsPane'});
  }

});
