//= require_self
//= require_tree ./multify

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
  },

};

