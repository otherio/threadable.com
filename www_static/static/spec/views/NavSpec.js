define(function(require) {
  var

    Nav  = require('views/Nav'),
    template = require('text!templates/nav.html'),
    multify  = require('multify'),
    User     = require('models/User');

  describe('Nav', function() {
    var view;
    beforeEach(function() {
      multify.set('current_user', false);
      view = new Nav();
    });

    describe("#template", function(){

      it("should be templates/nav.html", function(){
        expect(view.template.source).toEqual(_.template(template).source);
      });

    });

    describe("#templateHelpers", function(){

      it("sends the login status to the template", function() {
        expect(view.templateHelpers()).toEqual({
          loggedIn: false,
          current_user: false
        });
        var fakeUser = {};
        this.setCurrentUser(fakeUser);
        expect(view.templateHelpers()).toEqual({
          loggedIn: true,
          current_user: fakeUser
        });
      });

      it("renders the login status correctly", function() {
        view.render();
        expect(view.$el.text()).toContain('Login');

        this.setCurrentUser({});

        view.render();
        expect(view.$el.text()).toContain('Logout');

      });

    });

    describe("login", function() {
      it("logs you in", function() {
        spyOn(multify, 'login').andCallThrough();
        view.render();
        view.$('.login').click();
        expect(multify.login).toHaveBeenCalled();
      });
    });
  });

});
