//= require_self
//= require "./covered/util"
//= require "./covered/routes"
//= require_tree ./covered

Covered = {
  // _ready_callbacks: [],
  // ready: function(callback){
  //   this._ready_callbacks.push(callback);
  // },

  initialize: function(env){
    Covered.page = new Covered.Page(env);
    $(function(){
      Covered.page.trigger('domready');
    });
  }

};
