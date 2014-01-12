Covered.ApplicationRoute = Ember.Route.extend({

  model: function() {
    return Covered.CurrentUser.fetch().then(function(currentUser) {
      currentUser.loadOrganizations();
      return currentUser;
    });
  },

  actions: {
    willTransition: function(transition) {
      var transitions = this.controllerFor('application').get('transitions');
      transitions.unshift(transition);
      transitions.length = 2;
    }
  }

});

