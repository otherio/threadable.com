Multify = {};

_.extend(Multify, Backbone.Events);

Multify.views = {};
Multify.View = function(name, value){
  Multify.views[name] = _.template(value);
};


Multify.Router = Backbone.Router.extend({

  // routes: {
  //   "help":                 "help",    // #help
  //   "projects/:query":        "search",  // #search/kiwis
  //   "projects/:query/p:page": "search"   // #search/kiwis/p7
  // },

  // help: function() {
  //   ...
  // },

  // search: function(query, page) {
  //   ...
  // }

});


TEMP_FAKE_PROJECTS = [
  {name:'love steve'},
  {name:'eat sally'},
  {name:'pickup mustard'}
];

$(function(){
  $('body').html(Multify.views.application({projects:TEMP_FAKE_PROJECTS}));
});
