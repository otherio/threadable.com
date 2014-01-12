Covered.ForgotPasswordController = Ember.Controller.extend(Covered.CurrentUserMixin, {

  actions: {
    requestPasswordReset: function() {
      this.requestPasswordReset(this.get('emailAddress'));
    }
  },

  requestPasswordReset: function() {
    var request = $.post('/sign_in.json', {
      email_address: email_address,
      password: password
    });

    request.done(signInSuccessful.bind(this));
    request.fail(signInFailed.bind(this));

    return request;
  }


});
