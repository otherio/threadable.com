Covered.IndexController = Ember.Controller.extend({
  needs: ['application'],
  isSignedIn:  Ember.computed.alias('controllers.application.isSignedIn'),
  currentUser: Ember.computed.alias('controllers.application.currentUser')
});
