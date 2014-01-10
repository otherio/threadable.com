Covered.GroupsRoute = Ember.Route.extend({

  model: function(params){
    return this.modelFor('organization').get('groups');
  },

  renderTemplate: function() {
    // this.render('groups', {into: 'organization', outlet: 'pane1'});
  },

});
