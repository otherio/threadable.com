Covered.AddOrganizationMemberRoute = Ember.Route.extend({
  model: function() {
    return Covered.Member.create();
  },

  renderTemplate: function() {
    this.render('add_organization_member', {into: 'organization', outlet: 'pane2'});
    this.controllerFor('organization').set('focus', 'conversation');
  },

  actions: {
    transitionToOrganizationMembers: function(organization) {
      this.transitionTo("organization_members", organization.get('slug'));
      this.controllerFor('organization').set('focus', 'conversations');
    }
  }
});
