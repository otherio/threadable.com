Covered.OrganizationRoute = Ember.Route.extend({

  model: function(params){
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
