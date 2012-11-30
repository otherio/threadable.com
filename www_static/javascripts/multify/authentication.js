Multify.logged_in = !!Multify.session.authentication_token;
Multify.current_user_id = Multify.session.user_id;

Multify.logout = function(){
  Multify.current_user_id = null;
  delete Multify.session.authentication_token;
  Multify.session.save();
};

Multify.login = function(email, password){
  var request = Multify.authenticate(email, password);

  request.done(function(response){
    Multify.logged_in = true;
    Multify.current_user_id = response.user.id;

    Multify.session.user_id = response.user.id;
    Multify.session.authentication_token = response.authentication_token;
    Multify.session.save();

    // Multify.current_user(response.user;

    Multify.authentication_token = response.authentication_token;
    console.log('Login succeeded', response);
  });

  request.fail(function(){
    console.log('Login failed');
  });

  return request;
}

Multify.loadCurrentUser = function(){
  // return Multify.User.find(Multify.session.user_id)
  return Multify.get('/users/'+Multify.current_user_id)
    .success(function(user){
      Multify.current_user = user;
    })
    .fail(function(){
      console.error('failed to find user '+Multify.current_user_id);
      // Multify.logout();
    })
  ;
};


Multify.authenticate = function(email, password){
  return Multify.post('users/sign_in', {email: email, password: password});
};


Multify.request = function(method, path, params){
  params || (params = {});
  params._method = method;
  url = new URI(Multify.host)
  url.path = path;
  url.params =  params;
  return $.ajax({
    url: url.toString(),
    dataType: "jsonp",
    timeout: 1000,
  })
};

'GET PUT POST DELETE'.split(' ').forEach(function(method){

  Multify[method.toLowerCase()] = function(path, params){
    return Multify.request(method, path, params);
  };

});

View.helper(function(){
  return {
    logged_in: Multify.logged_in,
    current_user: Multify.current_user
  };
});
