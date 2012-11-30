Component = function(name, block){
  if (this instanceof Component){
    var self = Component.store[name] || (Component.store[name] = this);
    self.name = name;
    if (block) block.call(self, self);
  }else{
    var self = Component.store[name]
    if (self && block) block.call(self, self);
    return self;
  }
};

Component.store = {};

Component.prototype.render = function(options){
  options || (options = {});

  if (this.init && !this.init.run){
    this.init.run = true;
    this.init();
  }

  if (this.before_render) this.before_render(options);

  var element = $(View.render(this.name, options));
  element.data('options',options);

  if (this.after_render) this.after_render(element, options);

  return element;
};


Component.prototype.s = function(){
  return S('.'+this.name);
};
