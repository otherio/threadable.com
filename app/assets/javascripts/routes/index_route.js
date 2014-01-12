Covered.IndexRoute = Ember.Route.extend({

  redirect: function() {
    if (!Covered.isSignedIn()) return;

    Covered.Organization.fetch().then(redirectToFirstOrganization.bind(this));
    function redirectToFirstOrganization(organizations){
      var organization = organizations.objectAt(0);
      if (organization) this.transitionTo('organization', organization.get('slug'));
    }
  }

});
