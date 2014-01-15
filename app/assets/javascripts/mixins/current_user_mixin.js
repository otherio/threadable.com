Covered.CurrentUserMixin = Ember.Mixin.create({
  needs: "application",
  isSignedIn:  Ember.computed.alias('controllers.application.isSignedIn'),
  currentUser: Ember.computed.alias('controllers.application.currentUser'),
});
