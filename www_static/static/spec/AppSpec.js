define(function(require) {
  var
    App = require('App'),
    NavView = require('views/NavView'),
    Multify = require('multify'),
    session = require('session'),
    User = require('models/User');

  describe('App', function() {
    it("exists", function(){
      expect(App).toBeDefined();
    });

    it("has regions", function() {
      expect(App.navRegion).toBeDefined();
      expect(App.mainRegion).toBeDefined();
      expect(App.navRegion.el).toEqual(".nav-region");
      expect(App.mainRegion.el).toEqual(".main-region");
    });

    it("shows the nav view after init", function() {
      var navSpy = spyOn(NavView.prototype, 'render');
      spyOn(App.navRegion, 'show').andCallThrough();
      App.trigger('initialize:after');
      expect(navSpy).toHaveBeenCalled();
      expect(App.navRegion.show).toHaveBeenCalledWith(jasmine.any(NavView));
    });

    it("starts history", function() {
      Backbone.history = jasmine.createSpyObj('Backbone.history', ['start']);
      App.trigger('initialize:after');
      expect(Backbone.history.start).toHaveBeenCalled();
    });

    it("sets the current user from the session", function() {
      App.start({});
      session.set('user', 'someguy');
      expect(Multify.get('current_user')).toEqual(jasmine.any(User));
    });

  });
});
