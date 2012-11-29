Multify = {};

Multify.host = 'http://0.0.0.0:3000'

Multify.authenticate = function(email, password){
  var request = $.ajax({
    url: Multify.host+'/users/sign_in?_method=POST&email='+email+'&password='+password,
    dataType: "jsonp",
    timeout: 1000,
  });

  request.done(function(response){
    Multify.Session.update({
      user_id: response.user.id,
      authentication_token: response.authentication_token
    });
    Multify.current_user = response.user;
    Multify.authentication_token = response.authentication_token;
    console.log('Authentication succeeded', response);
  });

  request.fail(function(){
    console.log('Authentication failed');
  });

  return request;
};

