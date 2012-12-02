if (Multify.session.authentication_token){
  Multify.logged_in = true;
  Multify.current_user = new Multify.User(Multify.session.user);
}

Multify.logout = function(){
  Multify.logged_in = false;
  Multify.session.clear();
  Multify.trigger('logout');
};

Multify.login = function(email, password){
  return Multify.authenticate(email, password)

    .done(function(response){

      Multify.logged_in = true;

      Multify.session.user = response.user;
      Multify.session.authentication_token = response.authentication_token;
      Multify.session.save();

      Multify.current_user = new Multify.User(response.user);

      Multify.trigger('login');
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

