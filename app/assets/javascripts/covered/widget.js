Rails.Widget.prototype.page = function(){
  return this.node.parents('.page').data('page');
};

// Covered.Widget = function(name, block){
//   if (arguments.length === 0) return;

//   var Widget = Covered.widgets[name];
//   if (Widget === undefined){
//     if (typeof block !== 'function') return;
//     // widget = Covered.widgets[name] = this instanceof Covered.Widget ? this : new Covered.Widget;
//     // "subclass"
//     Widget = function(){ return this.initialize.apply(this, arguments); }
//     Widget.prototype = Object.create(Covered.Widget.prototype);
//     Widget.prototype.constructor = Widget;
//     Widget.name = name;
//     Covered.widgets[name] = Widget;
//   }
//   if (block) block.call(Widget.prototype, Widget.prototype);
//   return Widget;
// };

// Covered.Widget.prototype.$ = function(query){
//   var elements = $('.'+this.name);
//   if (arguments.length === 0) return elements;
//   return elements.find(query);
// };

// // Covered.Widget.prototype.on = function(types, selector, data, fn, one){
// //   selector = '.'+this.name+' '+(selector||'');
// //   Covered.page.$element.on(types, selector, data, fn, one);
// //   return this;
// // };
