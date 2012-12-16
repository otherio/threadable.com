define(function(require) {
  var
    App = require('App'),
    NavView = require('views/NavView'),
    Multify = require('multify'),
    LoggedOutRouter = require('logged_out/Router'),
    LoggedInRouter  = require('logged_in/Router'),
    User = require('models/User');

  describe('App', function() {
    it("exists", function(){
      expect(App).toBeDefined();
    });

    it("has a layout", function() {
      // trust me!
    });

    describe("when current user changes", function(){

      describe("and Backbone.history exists", function(){

        it("should set handlers to an empty array", function(){
          Multify.set('currentUser', null);
          expect(Backbone.history.handlers).toEqual([])
        });

      });

      describe("and Multify#user is set to a user", function(){
        it("should setup the logged in thing", function(){
          var user = new User;
          spyOn(user.projects, 'fetch')
          Multify.set('currentUser', user);
          expect(Backbone.history.start).toHaveBeenCalled();
          expect(App.router).toEqual(jasmine.any(LoggedInRouter));
          expect($('#body')).toHaveClass('logged-in');
          expect($('#body')).not.toHaveClass('logged-out');
          expect(user.projects.fetch).toHaveBeenCalled();
        });
      });

      describe("and Multify#user is set to a null", function(){
        it("should do the logged out thing", function(){
          Multify.set('currentUser', null);
          expect(Backbone.history.start).toHaveBeenCalled();
          expect(App.router).toEqual(jasmine.any(LoggedOutRouter));
          expect($('#body')).not.toHaveClass('logged-in');
          expect($('#body')).toHaveClass('logged-out');
        });
      });

      describe("when Multify#user is set to a null", function(){

      });



    });

    it("starts history", function() {

    });

    xit("sets the current user from the session", function() {
      // App.start({});
      // session.set('user', 'someguy');
      // expect(Multify.get('current_user')).toEqual(jasmine.any(User));
    });


  });
});
