Multify.View  = {
  templates: {},

  render: function(name, data) {
    var template = this.templates[name];
    if (typeof template === 'undefined') throw new Error('template '+name+' undefined');
    data = $.extend(this.data(), data);
    return template.render(data);
  },

  data: function(){
    return $.extend({}, this.helpers, {
      logged_in: Multify.logged_in,
      current_user: Multify.current_user
    });
  }
};


Multify.View.helpers = {

  render: function () {
    return function (text, render) {
      var matches = text.match(/^(.+?)(\(.*\))?$/);
      if (matches){
        var view = matches[1], data = matches[2];
        data = eval(data);
        return render(Multify.View.render(view, data));
      }else{
        return "<b>I have no idea how to render"+text+"</b>";
      }
    }
  }

};
