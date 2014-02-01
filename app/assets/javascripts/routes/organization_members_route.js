Covered.OrganizationMembersRoute = Ember.Route.extend({
  model: function() {
    return this.modelFor('organization').loadMembers();
  },

  renderTemplate: function() {
    this.render('organization_members', {into: 'organization', outlet: 'pane1'});
    this.controllerFor('organization').set('focus', 'conversations');
  },

  actions: {
    goToAdd: function() {
      this.transitionTo('add_organization_member', this.modelFor('organization'));
    }
  }
});
