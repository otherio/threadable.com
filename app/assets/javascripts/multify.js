Multify = {

  widgets: {},

  init: function(){
    Multify.init = $.noop;
    // initialize all widgets
    $.each(Multify.widgets, function(name, widget){
      if (widget.initialize) widget.initialize();
    });
  }

};


Multify.Widget = function(name, block){
  if (this instanceof arguments.callee); else
    return new Multify.Widget(name, block);
  Multify.widgets[name] = this;
  this.name = name;
  if (typeof block === 'function')
    block.call(this, this);
};
