Multify = {
  Views: {},
};

_.extend(Multify, Backbone.Events);




$(document).on('click', 'a[href]', function(event){
  var href = $(this).attr('href');
  if (href[0] === '/'){
    event.preventDefault();
    Multify.router.navigate(href, {trigger: true});
  }
});



$(function(){

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
    el: $('body'),
    projects: TEMP_FAKE_PROJECTS
  });

});
