Covered.OrganizationRoute = Ember.Route.extend({

  model: function(params){
    return this.store.find('organization', params.organization);
  },

  renderTemplate: function() {
    this.render('organization', {into: 'application'});
    this.render('groups', {into: 'organization', outlet: 'groupsPane'});
  }

});
