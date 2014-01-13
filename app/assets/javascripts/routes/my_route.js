Covered.MyRoute = Ember.Route.extend({

  setupController: function(controller, model) {
    this.controllerFor('navbar').set('group', null);
    this.controllerFor('organization').set('composeTarget', 'my');
  }

});
