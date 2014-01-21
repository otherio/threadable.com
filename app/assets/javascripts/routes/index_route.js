Covered.IndexRoute = Ember.Route.extend({

  redirect: function() {
    if (!Covered.isSignedIn()) return;
    return Covered.CurrentUser.fetch().then(function(currentUser) {
      var organization = currentUser.get('organizations').objectAt(0);
      if (organization) this.transitionTo('conversations', organization.get('slug'), 'my');
    }.bind(this));
  }

});
