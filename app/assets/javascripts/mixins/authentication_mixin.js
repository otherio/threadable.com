Covered.AuthenticationMixin = Ember.Mixin.create((function(){

  function signIn(email_address, password){
    var params = {
      email_address: email_address,
      password: password
    }
    return $.post('/sign_in.json', params).always(function(){
      Covered.CurrentUser.reload();
    });
  }

  function signOut(){
    Covered.CurrentUser.get().set('user_id', null);
    return $.post('/sign_out.json').always(function(){
      Covered.CurrentUser.reload();
    });
  }

  return {
    needs: "application",

    isSignedIn:  Ember.computed.alias('controllers.application.isSignedIn'),
    currentUser: Ember.computed.alias('controllers.application.currentUser'),

    signIn:   signIn,
    signOut:  signOut
  };

})());
