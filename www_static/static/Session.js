define(function(require){
  require('jquery-cookie');

  var Backbone = require('backbone');

  var Session = Backbone.Model.extend({
    cookieName: 'session',

    sync: function(method, ____, options) {
      var data = (method === 'read') ?
        readCookie(this.cookieName) :
        writeCookie(this.cookieName, this.toJSON());
      options.success(data);
      return this;
    }

  });

  // note: singleton
  return new Session();

  function readCookie(cookieName){
    var cookie = $.cookie(cookieName);
    if (cookie === null) return {};
    try{
      return JSON.parse(cookie);
    }catch(e){
      return {};
    };
  }

  function writeCookie(cookieName, data){
    $.cookie(cookieName, JSON.stringify(data));
    return data;
  }

});
