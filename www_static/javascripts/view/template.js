View.Template = function(name, value){
  this.name = name;
  this.value = value;
  View.templates[name] = this;
};

View.Template.prototype.render = function(data) {
  return Mustache.render(this.value, data);
};
