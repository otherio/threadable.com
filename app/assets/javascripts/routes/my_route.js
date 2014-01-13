Covered.MyRoute = Ember.Route.extend({

  setupController: function(controller, model) {
    this.controllerFor('navbar').setProperties({
      group: null,
      composeTarget: 'my'
    });
  }

});
