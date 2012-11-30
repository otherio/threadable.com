Events = {

  on: function(events, handler) {
    events = events.split(/\s+/);
    for (var i = 0; i < events.length; i++) {
      var event = events[i];
      this._events || (this._events = {});
      this._events[event] || (this._events[event] = []);
      this._events[event].push(handler);
    };
    return this;
  },

  trigger: function(event){
    args = [].slice.call(arguments, 1);
    args.push(event);
    this._events || (this._events = {});
    (this._events[event] || []).forEach(function(handler){
      handler.apply(this, args)
    }.bind(this));
    return this;
  }

};
