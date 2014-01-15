Covered.UngroupedRoute = Ember.Route.extend({

  setupController: function(controller, model) {
    this.controllerFor('navbar').set('group', null);
  }

});
