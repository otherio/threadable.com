Multify.Widget = function(name, block){
  if (arguments.length === 0) return;

  var widget = Multify.widgets[name];
  if (widget === undefined){
    if (typeof block !== 'function') return;
    widget = Multify.widgets[name] = this instanceof Multify.Widget ? this : new Multify.Widget;
    widget.name = name;
  }
  if (block) block.call(widget, widget);
  return widget;
};

Multify.Widget.prototype.$ = function(query){
  var elements = $('.'+this.name);
  if (arguments.length === 0) return elements;
  return elements.find(query);
};
