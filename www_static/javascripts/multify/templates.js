Multify.templates = {};
Multify.Template = function(name, value){
  Multify.templates[name] = _.template(value);
};

Multify.render = function(template, options){
  return Multify.templates[template](options);
};

