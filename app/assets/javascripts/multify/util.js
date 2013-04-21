Multify.Util = {};


Multify.Util.text2html = function(text){
  return $('<span>').text(text);
};

Multify.Util.EventFunctions = {
  bind: function(types, data, fn){
    $(this).bind(types, data, fn);
    return this;
  },
  trigger: function(type, data){
    $(this).trigger(type, data);
    return this;
  }
};
