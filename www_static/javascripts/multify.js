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



$(function(){

  Multify.authenticate('jared@change.org','password');

});



Multify.Session = {
  name: 'session',
  data: function(){
    return this._data || this.read();
  },
  read: function(){
    var cookie = $.cookie(this.name);
    if (cookie === null){
      return this.clear();
    }
    try{
      return this._data = JSON.parse(cookie);
    }catch(e){
      return this.clear();
    };
  },
  save: function(){
    $.cookie(this.name, JSON.stringify(this.data()));
    return this;
  },
  update: function(data){
    $.extend(this.data(), data);
    return this.save();
  },
  delete: function(key){
    delete this.data()[key];
    return this.save();
  },
  clear: function(){
    this._data = {};
    return this.save();
  }
};
