Covered.AllMyGroupsRoute = Ember.Route.extend({

  model: function(){
    return this.modelFor('organization').get('myConversations');
  },

  renderTemplate: function() {
    this.render('all_my_groups', {into: 'organization', outlet: 'conversationsPane'});
  }

});
