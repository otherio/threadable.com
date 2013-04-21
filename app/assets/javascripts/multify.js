//= require_self
//= require "./multify/util"
//= require "./multify/routes"
//= require_tree ./multify

Multify = {
  // _ready_callbacks: [],
  // ready: function(callback){
  //   this._ready_callbacks.push(callback);
  // },

  initialize: function(env){
    Multify.page = new Multify.Page(env);
    $(function(){
      Multify.page.trigger('domready');
    });
  }

};

