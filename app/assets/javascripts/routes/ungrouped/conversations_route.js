//= require ../conversations_route

Covered.UngroupedConversationsRoute = Covered.ConversationsRoute.extend({

  modelFetchOptions: function() {
    var organization = this.modelFor('organization');
    return {
      organization_id: organization.get('slug'),
      ungrouped: true
    };
  },

  setupController: function(controller, model) {
    this._super(controller, model);
    this.controllerFor('navbar').set('group', null);
    this.controllerFor('organization').set('composeTarget', 'ungrouped-conversations');
  },

  renderTemplate: function() {
    this.render('ungrouped_conversations', {into: 'organization', outlet: 'conversationsPane'});
  }

});