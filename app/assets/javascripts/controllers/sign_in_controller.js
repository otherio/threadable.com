Covered.SignInController = Ember.Controller.extend({

  reset: function(){
    this.setProperties({
      emailAddress: "",
      password: "",
      error: "",
    });
  },

  actions: {
    signIn: function() {
      var
        setError = function(value){ this.set('error', value); }.bind(this),
        request = $.post('/sign_in.json', {
          email_address: this.get('emailAddress'),
          password:      this.get('password'),
        });

      setError(null);

      request.done(function() {
        Covered.CurrentUser.reload().then(function(currentUser) {
          this.send('transitionToIndex');
          return currentUser;
        }.bind(this));
      }.bind(this));

      request.fail(function(xhr){
        var error = xhr.responseJSON && xhr.responseJSON.error || 'unknown error';
        setError(error);
      });
    }
  }

});
