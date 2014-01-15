Covered.SignOutRoute = Ember.Route.extend({
  beforeModel: function(){
    Covered.CurrentUser.signOut();
    this.transitionTo('index');
  }
});
