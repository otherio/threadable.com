Covered.SignInController = Ember.Controller.extend(Covered.AuthenticationMixin, {

  reset: function(){
    this.setProperties({
      emailAddress: "",
      password: "",
      error: "",
    });
  },

  actions: {
    signIn: function() {
      this.set('error', undefined);
      emailAddress = this.get('emailAddress');
      password     = this.get('password');
      var request = this.signIn(emailAddress, password);

      request.done(function() {
        this.transitionToRoute('/');
      }.bind(this));

      request.fail(function(xhr) {
        this.set('error', xhr.responseJSON.error);
      }.bind(this));
    }
  }

});
