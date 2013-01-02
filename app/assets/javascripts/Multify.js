define(function(require){

  var
    Backbone = require('backbone'),
    session  = require('Session'),
    URI      = require('uri'),
    User     = require('models/User');

  var multify = _.extend({}, Backbone.Events, {


    apiPrefix: 'api/',

    initialize: function(){
      this.session.fetch();
      var user = this.session.get('user');
      this.set('current_user', user ? new User(user) : null);
    },

    session: session,

    attributes: {},

    get: function(attr) {
      return this.attributes[attr];
    },

    set: function(attr, value, options){
      var current_value = this.attributes[attr];
      if (value !== current_value){
        this.attributes[attr] = value;
        if (!options || !options.silent)
          this.trigger('change:'+attr, value, current_value);
      }
      return value;
    },

    toJSON: function(){
      return _.clone(this.attributes);
    },

    join: function(userInfo, options){
      var newUser = new User(userInfo, {path: '/users/register'});
      newUser.save()
        .success(options?options.success:null)
        .fail(options?options.fail:null);
    },

    login: function(email, password){
      var postData = {email: email, password: password}
      return authenticate(multify.request('POST', '/users/sign_in', postData));
    },

    logout: function(){
      multify.request('DELETE', '/users/sign_out');
      session.clear();
      session.save();
      this.set('current_user', null);
    },

    request: function(method, path, params, options){
      if (path.slice(0,1) === '/') path = path.slice(1);
      params || (params = {});
      options || (options = {});
      params.authentication_token = multify.session.get('authentication_token');
      url = new URI(location.origin);
      url.path = multify.apiPrefix + path;
      url.params = params;

      options = $.extend({}, {
        type: method,
        url: url.toString(),
        dataType: 'json',
      }, options);

      return $.ajax(options);
    },

    sync: function(action, model, options) {
      var
        method = ({'create':'POST', 'read':'GET', 'update':'PUT', 'delete':'DELETE'})[action],
        params = {},
        path

      if (action === 'create' || action === 'update'){
        params[model.modelName] = model.toJSON();
      }
      path = model.path || '/'+pluralize(model.modelName);

      if ((action === 'update' || action === 'delete') && model.id) {
        path = path + '/' + model.id;
      }

      return multify.request(method, path, params, {context: model})
        .done(function(){ model.loaded = true; })
        .done(options.success)
        .fail(options.error)
    }
  });

  return multify;

  // private

  function authenticate(request){
    return request
      .done(function(response){
        session.set({
          user: response.user,
          authentication_token: response.authentication_token
        });
        session.save();

        multify.set('current_user', new User(response.user));
      })

      .fail(function(){
        console.log('Login failed');
        multify.logout();
      })
    ;
  }

  function pluralize(string) {
    return string+'s'; // make this awesome later
  }

});
