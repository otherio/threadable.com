define(function(require) {
  var
    Join    = require('views/logged_out/Join'),
    multify = require('multify');


  describe("join form", function() {
    var view;

    beforeEach(function() {
      view = new Join();
      view.render();
    });

    it("creates an account", function() {
      spyOn(multify, 'join');
      view.$('input[name=name]').val('foo');
      view.$('input[name=email]').val('foo@foo.foo');
      view.$('input[name=password]').val('passfoo');
      view.$('input[type=submit]').click();
      expect(multify.join).toHaveBeenCalledWith({
        'name': 'foo',
        'email': 'foo@foo.foo',
        'password': 'passfoo'
      });
    });
  });
});
