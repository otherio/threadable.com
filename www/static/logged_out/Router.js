define(function(require){

  var Marionette = require('marionette');
  var IndexView = require('views/logged_out/index');
  var JoinView = require('views/logged_out/join');

  return Marionette.AppRouter.extend({

    appRoutes: {
      ""          : "home",
      "join"      : "join",
      "*defaults" : "missing"
    },

    controller: {
      home: function(){
        App.layout.main.show(new IndexView);
      },
      join: function(){
        App.layout.main.show(new JoinView);
      },
      missing: function(path){
        console.warn('no route matches',path);
        App.router.navigate("/", {trigger:true});
      }
    }

  });

});
