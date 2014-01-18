//= require ../conversations_route

Covered.UngroupedConversationsRoute = Covered.ConversationsRoute.extend({

  setupController: function(controller, model) {
    this._super(controller, model);
    this.controllerFor('navbar').set('group', null);
    this.controllerFor('organization').set('composeTarget', 'ungrouped-conversations');
  },

  renderTemplate: function() {
    this.render('ungrouped_conversations', {into: 'organization', outlet: 'conversationsPane'});
  }

});
