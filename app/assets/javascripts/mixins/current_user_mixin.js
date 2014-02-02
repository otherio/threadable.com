Threadable.CurrentUserMixin = Ember.Mixin.create({
  needs: "application",
  currentUser: Ember.computed.alias('controllers.application.currentUser'),
});
