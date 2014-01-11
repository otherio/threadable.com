Covered.SignOutRoute = Ember.Route.extend({
  beforeModel: function(){
    $.post('/sign_out.json').always(signOut.bind(this));
    function signOut(){
      Covered.CurrentUser.reload();
      this.transitionTo('index');
    }
  }
});
