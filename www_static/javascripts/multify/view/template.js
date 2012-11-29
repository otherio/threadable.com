Multify.View.Template = function(name, value){
  this.name = name;
  this.value = value;
  Multify.View.templates[name] = this;
};

Multify.View.Template.prototype.render = function(data) {
  return Mustache.render(this.value, data);
};

