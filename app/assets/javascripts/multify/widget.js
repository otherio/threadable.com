Rails.Widget.prototype.page = function(){
  return this.node.parents('.page').data('page');
};

// Multify.Widget = function(name, block){
//   if (arguments.length === 0) return;

//   var Widget = Multify.widgets[name];
//   if (Widget === undefined){
//     if (typeof block !== 'function') return;
//     // widget = Multify.widgets[name] = this instanceof Multify.Widget ? this : new Multify.Widget;
//     // "subclass"
//     Widget = function(){ return this.initialize.apply(this, arguments); }
//     Widget.prototype = Object.create(Multify.Widget.prototype);
//     Widget.prototype.constructor = Widget;
//     Widget.name = name;
//     Multify.widgets[name] = Widget;
//   }
//   if (block) block.call(Widget.prototype, Widget.prototype);
//   return Widget;
// };

// Multify.Widget.prototype.$ = function(query){
//   var elements = $('.'+this.name);
//   if (arguments.length === 0) return elements;
//   return elements.find(query);
// };

// // Multify.Widget.prototype.on = function(types, selector, data, fn, one){
// //   selector = '.'+this.name+' '+(selector||'');
// //   Multify.page.$element.on(types, selector, data, fn, one);
// //   return this;
// // };
