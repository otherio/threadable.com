Covered.OrganizationRoute = Ember.Route.extend({

  model: function(params){
    this.controllerFor('organization').set('organization_slug', params.organization);
    return Covered.Organization.fetch(params.organization);
  },

  renderTemplate: function() {
    this.render('organization', {into: 'application'});
    this.render('groups', {into: 'organization', outlet: 'groupsPane'});
  },

  // setupController: function() {
  //   this._super.apply(this, arguments);
  // }

});
