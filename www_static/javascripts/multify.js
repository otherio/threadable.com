Multify = {
  Views: {},
};

_.extend(Multify, Backbone.Events);






TEMP_FAKE_PROJECTS = [
  {name:'love steve'},
  {name:'eat sally'},
  {name:'pickup mustard'}
];

$(function(){

  Multify.layout = new Multify.Views.Layout({el: $('body')});

  Multify.router = new Multify.Router;
  Backbone.history.start({
    pushState: true,
    root: '/'
  });
});
