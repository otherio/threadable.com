Multify.logout = function(){
  Multify.session.clear();
  Multify.set('current_user', null);
  Multify.set('logged_in', false);
};

Multify.login = function(email, password){
  return Multify.authenticate(email, password)

    .done(function(response){

      Multify.session.update({
        user: response.user,
        authentication_token: response.authentication_token
      });

      Multify.set('current_user', new Multify.User(response.user));
      Multify.set('logged_in', true);

      console.log('Login succeeded', response);
    })

    .fail(function(){
      console.log('Login failed');
    })
  ;
}

Multify.authenticate = function(email, password){
  return Multify.request('POST', 'users/sign_in', {
    email: email,
    password: password
  });
};

