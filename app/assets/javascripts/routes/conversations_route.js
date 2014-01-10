Covered.ConversationsRoute = Ember.Route.extend({

  model: function(params){
    return this.modelFor('group').get('conversations');
  },

  renderTemplate: function() {
    // this.render('groups', {into: 'organization', outlet: 'pane1'});
  },

});
