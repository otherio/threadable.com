define(function(require){

  var
    Multify = {},
    User = require('models/User');

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

        Multify.set('current_user', new User(response.user));
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

  Multify.request = function(method, path, params, options){
    params || (params = {});
    options || (options = {});
    params._method = method;
    if (Multify.logged_in){
      params.authentication_token = Multify.session.authentication_token
    }
    url = new URI(Multify.host)
    url.path = path;
    url.params = params;

    options = $.extend({}, {
      url: url.toString(),
      dataType: "jsonp",
      timeout: 2000,
    }, options);

    // console.log('REQUEST', options);

    return $.ajax(options);
  };

  Multify.sync = function(action, model, options) {
    var
      method = ({'create':'POST', 'read':'GET', 'update':'PUT', 'delete':'DELETE'})[action],
      params = {};

    if (action === 'create' || action === 'update'){
      params[model.constructor.modelName] = model.toJSON();
    }

    // console.log('SYNC', action, model, options);

    return Multify.request(method, model.path(), params, {context: model})
      .done(options.success)
      .fail(options.error)
  };

  return Multify;

});
