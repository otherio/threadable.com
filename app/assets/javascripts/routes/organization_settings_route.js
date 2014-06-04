Threadable.OrganizationSettingsRoute = Ember.Route.extend({

  model: function() {
    return this.modelFor('organization');
  },

  renderTemplate: function() {
    this.controllerFor('topbar').set('group', '');
    this.render('organization_settings', {into: 'organization', outlet: 'pane1'});
    this.controllerFor('organization').set('focus', 'conversations');
  }
});
