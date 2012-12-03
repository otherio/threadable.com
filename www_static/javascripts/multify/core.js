!function(){


Multify = {

  host: 'http://0.0.0.0:3000',

  current_user: null,
  logged_in: null,

  get: function(attr) {
    return this.attributes[attr];
  },

  set: function(attr, value){
    var current_value = self[attr];
    if (value !== current_value){
      this[attr] = value;
      this.trigger('change:'+attr, value, current_value);
    }
    return value;
  },

  templates: {},

  views: {}


};


Multify.Model = Backbone.Model.extend({

});

Multify.View = Backbone.View.extend({
  template: function(options){
    return T(this.name, options);
  }
});


function underscore(string) {
  return string.
    replace(/::/g, '/').
    replace(/([A-Z]+)([A-Z][a-z])/g, '$1_$2').
    replace(/([a-z\d])([A-Z])/g, '$1_$2').
    replace(/-/g, '_').
    toLowerCase();
};



// create:
//   M('User', {});
// get:
//   User = M('User');
// make:
//   user = new M('User');
function M(name, extension){
  var model = Multify[name], modelName, resourceName;
  if (model === undefined){
    modelName = underscore(name)
    resourceName = modelName+'s';
    model = Multify.Model.extend({
      modelName:    modelName,
      resourceName: resourceName,
      path:         '/'+resourceName
    });
    Multify[name] = model;
  }
  if (arguments.length > 1) model.extend(extension);
  return model;
};

// create:
//   new T('projects', '<ul class="projects">...</ul>');
// render:
//   html = T('projects', {});
function T(name, value_or_options){
  if (this instanceof T){
    Multify.templates[name] = _.template(value_or_options);
    return;
  }
  var template = Multify.templates[name]
  if (template) return template(value_or_options);
  throw new Error('missing template '+name);
};

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


// WHILE DEVELOPING / DEBUGGING
window.M = M;
window.V = V;
window.T = T;

$.extend(Multify, Backbone.Events);


$(function(){

  Multify.router = new Multify.Router;
  Multify.layout = new V('layout');

  Multify.on('change:logged_in', function(){
    Multify.layout.render();
  });

  if (Multify.session.authentication_token){
    Multify.set('current_user', new Multify.User(Multify.session.user));
    Multify.set('logged_in', true);
  }else{
    Multify.set('current_user', null);
    Multify.set('logged_in', false);
  }

  Backbone.history.start({
    pushState: true,
    root: '/'
  });

});




// Multify.set('current_user', 1)
// Multify.set('current_user', 1)
// Multify.set('current_user', 1)
