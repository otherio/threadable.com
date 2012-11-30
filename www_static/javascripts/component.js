Component = function(name, block){
  if (this instanceof Component){
    var self = Component.store[name] || (Component.store[name] = this);
    self.name = name;
    if (block) self.on('init', block);
  }else{
    var self = Component.store[name];
    if (!self) throw new Error('Component '+name+' is not defined.');
    if (block) self.on('init', block);
    return self;
  }
};

Component.store = {};

$.extend(Component.prototype, Events);

Component.prototype.render = function(options){
  options || (options = {});

  if (!this.initialized){
    this.initialized = true;
    this.trigger('init', this);
  }

  this.trigger('before_render', options);

  var element = $(View.render(this.name, options));
  element.data('options',options);

  this.trigger('after_render', element, options);

  return element;
};


Component.prototype.s = function(){
  return S('.'+this.name);
};
