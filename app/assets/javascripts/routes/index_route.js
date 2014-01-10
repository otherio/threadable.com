Covered.IndexRoute = Ember.Route.extend({
  beforeModel: function(transition) {
    var self = this;
    if (this.controllerFor('application').get('isSignedIn')){

      this.controllerFor('application').get('currentUser').then(function(currentUser){
        currentUser.get('organizations').then(function(organisations){
          var organization = organisations.objectAt(0);
          if (!organization) alert('you have no organizations');
          transition.abort();
          self.transitionTo('organization', organization.get('slug'));
          return organisations;
        });
        return currentUser;
      });
    }
  }
});
