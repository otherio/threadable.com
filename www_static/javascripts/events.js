Events = {

  on: function(event, handler) {
    this._events || (this._events = {});
    this._events[event] || (this._events[event] = []);
    this._events[event].push(handler);
    return this;
  },

  trigger: function(event){
    this._events || (this._events = {});
    (this._events[event] || []).forEach(function(){

    });
  }

};
