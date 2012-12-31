define(function(require) {
  var

    Nav  = require('views/Nav'),
    template = require('text!nav.html'),
    multify  = require('Multify'),
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
        expect(view.$el.text()).toContain('Sign in');

        var user = new User({name: 'Jessy Pinker'});
        this.setCurrentUser(user);

        view.render();
        expect(view.$el.text()).toContain('Sign out');

      });

      it("renders the name of the current user", function() {
        var user = new User({name: 'Jessy Pinker'});
        this.setCurrentUser(user);
        view.render();
        expect(view.$el.text()).toContain('Jessy Pinker');
      });
    });

    describe("login", function() {
      it("logs you in", function() {
        spyOn(multify, 'login').andCallThrough();
        view.render();
        view.$('#login-menu').click();
        view.$('form.login input[name=email]').val('jared@change.org');
        view.$('form.login input[name=password]').val('password');
        view.$('form.login input[type=submit]').click();
        expect(multify.login).toHaveBeenCalledWith('jared@change.org', 'password');
      });
    });
  });

});
