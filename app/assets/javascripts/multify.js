//= require_self
//= require_tree ./multify

Multify = {

  widgets: {},
  pages: {},

  pageName: function(){
    return ENV.pageName;
  }
};

// i can't believe this isn't already here.
// thank you, stackoverflow.
RegExp.quote = function(str) {
  return (str+'').replace(/([.?*+^$[\]\\(){}|-])/g, "\\$1");
};
