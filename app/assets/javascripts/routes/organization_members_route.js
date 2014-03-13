Threadable.OrganizationMembersRoute = Ember.Route.extend({
  model: function() {
    return this.modelFor('organization').loadMembers();
  },

  renderTemplate: function() {
    this.render('organization_members', {into: 'organization', outlet: 'pane1'});
    this.controllerFor('topbar').set('group', '');
    this.controllerFor('organization').set('focus', 'conversations');
  }
});
