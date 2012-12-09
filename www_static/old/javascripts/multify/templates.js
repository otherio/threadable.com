Multify.templates = {};
Multify.Template = function(name, value){
  Multify.templates[name] = _.template(value);
};

Multify.Template.render = function(name, options){
  return Multify.templates[name](options);
};
