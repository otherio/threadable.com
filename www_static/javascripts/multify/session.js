Multify.session = {
  name: 'session',

  // TODO we dont need this wrapper
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
