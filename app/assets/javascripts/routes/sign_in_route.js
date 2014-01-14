// For more information see: http://emberjs.com/guides/routing/

Covered.SignInRoute = Ember.Route.extend({
  beforeModel: function(transition){
    if (this.controllerFor('application').get('isSignedIn')){
      transition.abort();
      this.transitionTo('index');
    }
  },
  setupController: function(controller, context){
    controller.reset();
  },
  actions: {
    transitionToIndex: function() {
      this.transitionTo('index');
    }
  }
});
