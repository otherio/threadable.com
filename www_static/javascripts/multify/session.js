!function(){

  var cookieName = 'session';

  function Session(){};

  Session.prototype.reload = function(){
    $.extend(this, readCookie());
    return this;
  };

  Session.prototype.save = function(){
    var data = {};
    for (p in this)
      if (this.hasOwnProperty(p))
        data[p] = this[p];
    writeCookie(data);
    return data;
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

