define(function(require) {
  var
    Join    = require('views/logged_out/Join'),
    multify = require('Multify'),
    testResponses = require('spec/helpers/TestResponses');

  describe("join form", function() {
    var view;

    beforeEach(function() {
      view = new Join();
      view.render();

      spyOn(multify, 'join').andCallThrough();
      spyOn(multify, 'login').andCallThrough();

      view.$('input[name=name]').val('foo');
      view.$('input[name=email]').val('foo@foo.foo');
      view.$('input[name=password]').val('passfoo');
      view.$('input[type=submit]').click();
    });

    it("creates an account", function() {
      expect(multify.join).toHaveBeenCalledWith({
        'name': 'foo',
        'email': 'foo@foo.foo',
        'password': 'passfoo'
      },
      {
        success: jasmine.any(Function)
      });
    });

    it("logs in", function() {
      mostRecentAjaxRequest().response(testResponses.register.success);
      expect(multify.login).toHaveBeenCalledWith('foo@foo.foo', 'passfoo');
    });

  });
});
