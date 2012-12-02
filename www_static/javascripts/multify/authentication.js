Multify.logged_in = !!Multify.session.authentication_token;
Multify.current_user_id = Multify.session.user_id;
Multify.current_user = null;

Multify.logout = function(){
  Multify.logged_in = false;
  Multify.current_user_id = null;
  Multify.current_user = null;
  delete Multify.session.authentication_token;
  Multify.session.save();
  Multify.trigger('logout');
};

Multify.login = function(email, password){
  var request = Multify.authenticate(email, password);

  request.done(function(response){
    Multify.logged_in = true;
    Multify.current_user_id = response.user.id;
    Multify.current_user = new Multify.User(response.user);

    Multify.session.user_id = response.user.id;
    Multify.session.authentication_token = response.authentication_token;
    Multify.session.save();
    Multify.authentication_token = response.authentication_token;
    Multify.trigger('login');
    console.log('Login succeeded', response);
  });

  request.fail(function(){
    console.log('Login failed');
  });

  return request;
}

Multify.loadCurrentUser = function(){

  var user = new Multify.User({id: Multify.current_user_id});

  return user.fetch()
    .success(function(user){
      Multify.current_user = new Multify.User(user);
    })
    .fail(function(){
      console.error('failed to find user '+Multify.current_user_id);
      // Multify.logout();
    })
  ;
};


Multify.authenticate = function(email, password){
  return Multify.request('POST', 'users/sign_in', {
    email: email,
    password: password
  });
};





// View.helper(function(){
//   return {
//     logged_in: Multify.logged_in,
//     current_user: Multify.current_user
//   };
// });
