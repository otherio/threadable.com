!function(){

  var cookieName = 'session';

  function Session(){};

  Session.prototype.reload = function(){
    $.extend(this, readCookie());
    return this;
  };

  Session.prototype.save = function(){
    var p, data = {};
    for (p in this)
      if (this.hasOwnProperty(p))
        data[p] = this[p];
    writeCookie(data);
    return this;
  };

  Session.prototype.clear = function(){
    for (var p in this)
      if (this.hasOwnProperty(p))
        delete this[p];
    return this.save();
  };

  Multify.session = new Session().reload();

  function readCookie(){
    var cookie = $.cookie(cookieName);
    if (cookie === null) return {};
    try{
      return JSON.parse(cookie);
    }catch(e){
      return {};
    };
  }

  function writeCookie(data){
    $.cookie(cookieName, JSON.stringify(data));
    return this;
  }

}();

