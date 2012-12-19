define(function(require){

  var
    Backbone = require('backbone'),
    session  = require('session'),
    URI      = require('uri'),
    User     = require('models/User');

  var multify = _.extend({}, Backbone.Events, {

    host: 'http://0.0.0.0:3000',
    dataType: 'jsonp',

    initialize: function(){
      this.session.fetch();
      var user = this.session.get('user');
      this.set('current_user', user ? new User(user) : null);
    },

    host: 'http://0.0.0.0:3000',

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

    logout: function(){
      session.clear();
      session.save();
      this.set('current_user', null);
    },

    login: function(email, password){
      return authenticate(email, password)

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
    },

    request: function(method, path, params, options){
      params || (params = {});
      options || (options = {});
      params._method = method;
      params.authentication_token = multify.session.get('authentication_token');
      url = new URI(multify.host);
      url.path = path;
      url.params = params;

      options = $.extend({}, {
        url: url.toString(),
        dataType: this.dataType,
        timeout: 2000,
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

      return multify.request(method, path, params, {context: model})
        .done(function(){ model.loaded = true; })
        .done(options.success)
        .fail(options.error)
    }
  });

  return multify;

  // private

  function authenticate(email, password){
    return multify.request('POST', '/users/sign_in', {
      email: email,
      password: password
    });
  }

  function pluralize(string) {
    return string+'s'; // make this awesome later
  }

});
