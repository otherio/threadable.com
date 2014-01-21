Covered.MutedConversationsRoute = Ember.Route.extend({

  model: function(params) {
    var
      groupSlug = this.modelFor('group'),
      organization = this.modelFor('organization');

    return Covered.Conversation.fetchByGroupAndScope(organization, groupSlug, 'muted_conversations');
  },

  setupController: function(controller, context, transition) {
    this._super(this.controllerFor('conversations'), context, transition);
  },

  renderTemplate: function() {
    this.render('conversations', {into: 'organization', outlet: 'conversationsPane'});
  }

});
