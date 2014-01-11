Covered.ConversationsIndexRoute = Ember.Route.extend({

  model: function(params){
    var organization = this.modelFor('organization');
    var group = this.modelFor('group');
    if(!group) {
      // this is stupid.
      group = this.controllerFor('group').get('model');
    }
    console.log('loading conversations for ', group);

    return Covered.Conversation.fetch({organization_id: organization.get('slug'), group_id: group.get('slug')});
  },

  renderTemplate: function() {
    this.controllerFor('organization').set('focus', 'conversations');
    // this.render('groups', {into: 'organization', outlet: 'pane1'});
  },

});
