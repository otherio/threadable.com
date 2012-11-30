Component = function(name, block){
  if (arguments.length === 0) return (this === window) ? new Component : this;
  // if (this === window) return new Component('use new Component');
  var self = Component.store[name] || (Component.store[name] = new Component);
  self.name = name;
  if (block) block.apply(self);
  return self;
};

Component.store = {};

// Component.uuid = (function(){
//   var uuid = 0;
//   return function(){ return uuid += 1; }
// })();

Component.prototype.render = function(){


  if (this.init && !this.init.run){
    this.init.run = true;
    this.init();
  }

  var args = [].slice.call(arguments, 0);
  args.unshift(this.name)

  var html = $(View.render.apply(View, args));

  console.log('Render Component:', this.name, html);

  // var uuid = Component.uuid();

  // html = html.replace(/^\s*<\w+ /, function(s,n){
  //   return n === 0 ? s+'data-component_uuid="'+uuid+'" ' : s;
  // });
  return html;
};


Component.prototype.s = function(){
  return S('.'+this.name);
};
