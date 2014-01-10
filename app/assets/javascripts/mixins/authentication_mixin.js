Covered.AuthenticationMixin = Ember.Mixin.create((function(){

  function signIn(email_address, password){
    var request = $.post('/sign_in.json', {
      email_address: email_address,
      password: password
    });

    request.done(signInSuccessful.bind(this));
    request.fail(signInFailed.bind(this));

    return request;
  }

  function signInSuccessful(response){
    if (response.current_user){
      var currentUser = this.store.find('user', response.current_user.id);
      // var currentUser = this.store.buildRecord(Covered.User, response.current_user.id, response.current_user);
      this.signInAs(currentUser);
    }else{
      this.set('error', 'an unknown error has occured');
    }
  }

  function signInFailed() {
    console.log('signin failed');
    _signOut.apply(this);
  }

  function signInAs(user){
    console.log('signing is as', user);
    this.set('currentUser', user);
    this.set('isSignedIn', true);
    return this;
  }

  function signOut(){
    console.log('signing out');
    _signOut.apply(this);
    $.post('/sign_out.json');
  }

  function _signOut() {
    this.set('currentUser', null);
    this.set('isSignedIn', false);
    // TODO we should flush the entire datastore here
  }

  return {
    needs: "application",

    isSignedIn:  Ember.computed.alias('controllers.application.isSignedIn'),
    currentUser: Ember.computed.alias('controllers.application.currentUser'),

    signIn:   signIn,
    signOut:  signOut,
    signInAs: signInAs
  };

})());
