Covered.IndexRoute = Ember.Route.extend({

  redirect: function() {
    if (!Covered.isSignedIn()) return;
    return Covered.CurrentUser.fetch().then(function(currentUser) {
      var organization = currentUser.get('organizations').objectAt(0);
      if (organization) this.transitionTo('my_conversations', organization.get('slug'));
    }.bind(this));
  }

});
