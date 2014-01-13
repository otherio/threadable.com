Covered.MyConversationsRoute = Ember.Route.extend({

  model: function() {
    return Covered.Conversation.fetch({
      organization_id: this.modelFor('organization').get('slug'),
      my: true
    });
  },

  setupController: function(controller, model) {
    this._super(controller, model);
    this.controllerFor('navbar').set('group', null);
  },

  renderTemplate: function() {
    this.render('my_conversations', {into: 'organization', outlet: 'conversationsPane'});
  }

});
