Threadable.IndexRoute = Ember.Route.extend({

  redirect: function() {
    return Threadable.CurrentUser.fetch().then(function(currentUser) {
      var organization = currentUser.get('currentOrganization');
      if (organization) this.transitionTo('conversations', organization.get('slug'), 'my');
    }.bind(this));
  }

});
