View = {
  templates: {},

  render_page: function(){
    $('body').html( this.render('layout') );
    this.renderComponents();
  },

  renderComponents: function(element){
    element || (element = document.body);
    $(element).find('.component').each(function(){
      var
        element = $(this),
        data = element.data(),
        name = data.name;
      delete data.name;
      element.replaceWith(Component(name).render(data));
    });
  },

  render: function(name, data) {
    var template = this.templates[name];
    if (typeof template === 'undefined') throw new Error('template '+name+' undefined');
    data = $.extend(this.helpers(), data);
    return template.render(data);
  },

  _helpers: [],

  helper: function(helper){
    this._helpers.push(helper);
  },

  helpers: function(){
    var helpers = {};
    this._helpers.forEach(function(helper){
      if (typeof helper === 'function'){
        helper = helper();
      }
      $.extend(helpers, helper);
    });
    return helpers;
  }
};


View.helper({

  render_template: function () {
    return function (text, render) {
      var args = View.renderTextToArguments(text);
      if (args === null) return "<b>I have no idea how to render"+text+"</b>";
      return View.render.apply(View, args);
    };
  },

  render_component: function(){
    return function (text, render) {
      var args = View.renderTextToArguments(text);
      if (args === null) return "<b>I have no idea how to render"+text+"</b>";
      var name = args.shift();
      var component = Component(name);
      return component.render.apply(component, args);
    };
  },

});

View.renderTextToArguments = function(text){
  var matches = text.match(/^(.+?)(\(.*\))?$/);
  if (matches === null) return false;
  var name = matches[1], args = matches[2];
  args = args ?
    eval('['+args.slice(1,-1)+']') :
    [];
  args.unshift(name);
  return args;
};


