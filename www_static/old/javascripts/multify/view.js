Multify.View = Backbone.View.extend({
  template: function(options){
    return Multify.Template.render(this.name, options);
  }
});

// create:
//   V('layout', {})
// get:
//   Layout = V('layout');
// make:
//   layout = new V('layout');
function V(name, extension){
  var view = Multify.views[name];

  if (this instanceof V) return new view(extension);

  if (view === undefined)
    Multify.views[name] = view = Multify.View.extend({
      name:name
    });

  if (arguments.length > 1) _.extend(view.prototype, extension);
  return view;
};
