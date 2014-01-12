Covered.ConversationsRoute = Ember.Route.extend({

  model: function(params){
    var organization = this.modelFor('organization');
    var group = this.modelFor('group');
    return Covered.Conversation.fetch({
      organization_id: organization.get('slug'),
      group_id: group.get('slug')
    });
  },

  renderTemplate: function() {
    this.controllerFor('organization').set('focus', 'conversations');
  },

});
