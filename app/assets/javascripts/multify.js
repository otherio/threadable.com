//= require_self
//= require_tree ./multify

Multify = (function(){

  var self, pageName;

  return self = {

    widgets: {},
    pages: {},

    pageName: function(){
      return pageName || (pageName = $('#page').attr('name'));
    },

  };

})();
