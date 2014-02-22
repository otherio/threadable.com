Threadable.OrganizationMemberRoute = Ember.Route.extend({
  model: function(params) {
    return this.modelFor('organization_members').findBy('slug', params.member);
  },

  renderTemplate: function() {
    this.render('organization_member', {into: 'organization', outlet: 'pane2'});
    this.controllerFor('organization').set('focus', 'conversation');
  },

  actions: {
    transitionToOrganizationMembers: function(organization) {
      this.transitionTo("organization_members", organization.get('slug'));
      this.controllerFor('organization').set('focus', 'conversations');
    }
  }
});
