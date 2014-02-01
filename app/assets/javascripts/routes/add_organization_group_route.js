Covered.AddOrganizationGroupRoute = Ember.Route.extend({
  model: function(group) {
    return Covered.Group.create({color: "#9b59b6"});
  },

  renderTemplate: function() {
    this.render('add_organization_group', {into: 'organization', outlet: 'pane1'});
    this.controllerFor('organization').set('focus', 'conversations');
  },

  actions: {
    transitionToGroup: function(group) {
      this.transitionTo('conversations', group.get('slug'));
    }
  }
});
