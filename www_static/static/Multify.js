define(function(require){

  var
    Backbone = require('backbone'),
    session  = require('session'),
    URI      = require('uri'),
    User     = require('models/User');

  var Multify = {

    initialize: function(){
      this.session.fetch();
      var user = this.session.get('user');
      this.set('currentUser', user ? new User(user) : undefined);
    },

    host: 'http://0.0.0.0:3000',

    session: session,

    attributes: {
      currentUser: null
    },

    get: function(attr) {
      return this.attributes[attr];
    },

    set: function(attr, value){
      var current_value = this.attributes[attr];
      if (value !== current_value){
        this.attributes[attr] = value;
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
      this.set('currentUser', undefined);
    },

    login: function(email, password){
      return authenticate(email, password)

        .done(function(response){

          session.set({
            user: response.user,
            authentication_token: response.authentication_token
          });
          session.save();

          Multify.set('currentUser', new User(response.user));
        })

        .fail(function(){
          console.log('Login failed');
          Multify.logout();
        })
      ;
    },

    request: function(method, path, params, options){
      params || (params = {});
      options || (options = {});
      params._method = method;
      params.authentication_token = Multify.session.get('authentication_token');
      url = new URI(Multify.host);
      url.path = path;
      url.params = params;

      options = $.extend({}, {
        url: url.toString(),
        dataType: "jsonp",
        timeout: 2000,
      }, options);

      return $.ajax(options);
    },

    sync: function(action, model, options) {
      var
        method = ({'create':'POST', 'read':'GET', 'update':'PUT', 'delete':'DELETE'})[action],
        params = {};

      if (action === 'create' || action === 'update'){
        params[model.constructor.modelName] = model.toJSON();
      }

      return Multify.request(method, model.path, params, {context: model})
        .done(options.success)
        .fail(options.error)
    }
  };

  _.extend(Multify, Backbone.Events);

  return Multify;

  // private

  function authenticate(email, password){
    return Multify.request('POST', '/users/sign_in', {
      email: email,
      password: password
    });
  }

});
