Multify.logged_in = Multify.session.authentication_token;

Multify.logout = function(){
  delete Multify.session.authentication_token;
  Multify.session.save();
};

Multify.login = function(email, password){
  var request = Multify.authenticate(email, password);

  request.done(function(response){
    Multify.logged_in = true;

    Multify.session.user_id = response.user.id;
    Multify.session.authentication_token = response.authentication_token;
    Multify.session.save();

    Multify.user = response.user;

    Multify.authentication_token = response.authentication_token;
    console.log('Login succeeded', response);
  });

  request.fail(function(){
    console.log('Login failed');
  });

  return request;
}

// Multify.user = function(){
//   if (!Multify.logged_in()) return null;
//   var user_id = Multify.session.data().user_id;

//   Multify.get('/users/'+user_id).done(function(){ console.log(arguments); })
// };


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

})
