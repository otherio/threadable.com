Backbone.Model.prototype.path = function(){
  return this.isNew() ?
    this.constructor.path :
    this.constructor.path+'/'+(this.param || this.id);
};

Backbone.Collection.prototype.path = function(){
  return this.constructor.path;
};


Multify = {
  Views: {},
};

_.extend(Multify, Backbone.Events);


Multify.host = 'http://0.0.0.0:3000';

Multify.ready = function(callback){
  if (callback) return this.on('ready', callback);
  this.ready = function(callback){
    if (callback) setTimeout(callback);
    return this;
  }
  return this.trigger('ready');
};

Multify.init = function(){

  if (Multify.logged_in && !Multify.current_user){
    Multify.loadCurrentUser().success(function(){ Multify.ready(); });
  }else{
    Multify.ready();
  }

};


$(document).on('click', 'a[href=""],a[href="#"]', function(event){
  event.preventDefault();
});

$(document).on('click', 'a[href]', function(event){
  var href = $(this).attr('href');
  if (href[0] === '/'){
    event.preventDefault();
    Multify.router.navigate(href, {trigger: true});
  }
});


$(function(){
  Multify.init();
});

Multify.ready(function(){

  Multify.router = new Multify.Router;
  Backbone.history.start({
    pushState: true,
    root: '/'
  });

  Multify.router.on("route:project", function(project_slug){
    Multify.layout.mainProjectList.setActiveLink();
  });


  Multify.layout = new Multify.Views.Layout;

  Multify.layout.render();


});

