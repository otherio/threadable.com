Covered.AddOrganizationGroupRoute = Ember.Route.extend({
  model: function(group) {
    return Covered.Group.create({
      color: "#9b59b6",
      autoJoin: true
    });
  },

  renderTemplate: function() {
    this.render('add_organization_group', {into: 'organization', outlet: 'pane1'});
    this.controllerFor('organization').set('focus', 'conversations');
  },

  actions: {
    transitionToGroupMembers: function(group) {
      this.transitionTo('group_members', group.get('slug'));
    },
    transitionToGroupCompose: function(group) {
      this.transitionTo('compose_conversation', group.get('slug'));
    }
  }
});
