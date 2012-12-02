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

  // if (Multify.logged_in){
  //   Multify.trigger('login');
  // }else{
  //   Multify.trigger('logout');
  // }

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




  TEMP_FAKE_PROJECTS = [
    new Multify.Project({
      name:'love steve',
      slug:'love-steve'
    }),
    new Multify.Project({
      name:'eat sally',
      slug:'eat-sally'
    }),
    new Multify.Project({
      name:'pickup mustard',
      slug:'pickup-mustard'
    })
  ];


  Multify.router = new Multify.Router;
  Backbone.history.start({
    pushState: true,
    root: '/'
  });

  Multify.layout = new Multify.Views.Layout({
    projects: TEMP_FAKE_PROJECTS
  });

});
