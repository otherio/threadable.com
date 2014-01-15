Covered.GroupConversationsRoute = Covered.ConversationsRoute.extend({

  modelFetchOptions: function(params){
    var organization = this.modelFor('organization');
    var group = this.modelFor('group');
    return {
      organization_id: organization.get('slug'),
      group_id: group.get('slug')
    };
  },

  renderTemplate: function() {
    this.render('group_conversations', {into: 'organization', outlet: 'conversationsPane'});
    this.controllerFor('organization').set('focus', 'conversations');
  }

});
