Threadable.OrganizationMemberRoute = Ember.Route.extend({
  model: function(params) {
    return this.modelFor('organization').get('members').findBy('slug', params.member);
  },

  renderTemplate: function() {
    this.render('organization_member', {into: 'organization', outlet: 'pane2'});
    this.controllerFor('organization').set('focus', 'conversation');
  }
});
