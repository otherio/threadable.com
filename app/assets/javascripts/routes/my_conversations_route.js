Covered.MyConversationsRoute = Covered.ConversationsRoute.extend({

  modelFetchOptions: function() {
    var organization = this.modelFor('organization');
    return {
      organization_id: organization.get('slug'),
      my: true
    };
  },

  setupController: function(controller, model) {
    this._super(controller, model);
    this.controllerFor('navbar').set('group', null);
  },

  renderTemplate: function() {
    this.render('my_conversations', {into: 'organization', outlet: 'conversationsPane'});
  }

});
