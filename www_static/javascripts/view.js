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
      var v = View.renderTextToArguments(text);
      if (v === null) return "<b>I have no idea how to render"+text+"</b>";
      return View.render(v.name, v.options);
    };
  },

  render_component: function(){
    return function (text, render) {
      var c = View.renderTextToArguments(text);
      if (c === null) return "<b>I have no idea how to render"+text+"</b>";
      return Component(c.name).render(v.options);
    };
  },

});

View.renderTextToArguments = function(text){
  var matches = text.match(/^(.+?)(\(.*\))?$/);
  if (matches === null) return false;
  var name = matches[1], options = matches[2];
  options = eval(options);
  return {name:name, options:options}
};


