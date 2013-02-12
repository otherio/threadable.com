Multify = {

  widgets: {},
  pages: {},

  initialize: function(){
    this.init = $.noop;
    this.initializeWidgets();
    this.initializePage();
  },

  initializeWidgets: function(){
    $.each(this.widgets, function(name, widget){
      if (widget.initialize) widget.initialize();
    });
  },

  initializePage: function(){
    var page = this.pages[this.pageName()];
    if (page) page.initialize();
  },

  pageName: function(){
    return $('#page').attr('name');
  }

};


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
