define(function(require) {
  var

    NavView  = require('views/NavView'),
    template = require('text!templates/nav.html'),
    Multify  = require('multify'),
    User     = require('models/User');

  describe('NavView', function() {
    var view;
    beforeEach(function() {
      Multify.set('current_user', false);
      view = new NavView();
    });

    describe("#template", function(){

      it("should be templates/nav.html", function(){
        expect(view.template.source).toEqual(_.template(template).source);
      });

    });

    describe("#templateHelpers", function(){

      it("sends the login status to the template", function() {
        expect(view.templateHelpers()).toEqual({loggedIn: false, current_user: false});
        Multify.set('current_user', 'some_guy');
        expect(view.templateHelpers()).toEqual({loggedIn: true, current_user: 'some_guy'});
      });
    });

    describe("login", function() {
      it("logs you in", function() {
        spyOn(Multify, 'login').andCallThrough();
        view.render();
        view.$('.login').click();
        expect(Multify.login).toHaveBeenCalled();
      });
    });
  });

});
