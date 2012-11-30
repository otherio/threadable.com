View = {
  templates: {},

  helpers: [],

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

  render: function () {
    return function (text, render) {
      var matches = text.match(/^(.+?)(\(.*\))?$/);
      if (matches){
        var view = matches[1], data = matches[2];
        data = eval(data);
        return render(View.render(view, data));
      }else{
        return "<b>I have no idea how to render"+text+"</b>";
      }
    }
  }

});



