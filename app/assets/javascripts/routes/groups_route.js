Covered.GroupsRoute = Ember.Route.extend({

  model: function(params){
    var organization = this.modelFor('organization');
    return Covered.Group.fetch({organization_id: organization.get('slug')});
  },

  renderTemplate: function() {
    // this.render('groups', {into: 'organization', outlet: 'pane1'});
  },

});
