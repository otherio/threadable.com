Covered.OrganizationRoute = Ember.Route.extend({

  model: function(params){
    this.controllerFor('organization').set('organization_slug', params.organization);
    return Covered.Organization.fetch(params.organization);
  },

  setupController: function(controller, model) {
    this._super(controller, model);
    this.controllerFor('navbar').set('organization', model);
  },

  renderTemplate: function() {
    this.render('organization', {into: 'application'});
    this.render('groups', {into: 'organization', outlet: 'groupsPane'});
  }

});
