Threadable.IndexRoute = Ember.Route.extend({

  redirect: function() {
    return Threadable.CurrentUser.fetch().then(function(currentUser) {
      var organization = currentUser.get('organizations').objectAt(0);
      if (organization) this.transitionTo('conversations', organization.get('slug'), 'my');
    }.bind(this));
  }

});
