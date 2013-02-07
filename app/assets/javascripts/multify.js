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
  if (this instanceof arguments.callee); else
    return new Multify.Widget(name, block);
  Multify.widgets[name] = this;
  this.name = name;
  if (typeof block === 'function')
    block.call(this, this);
};
