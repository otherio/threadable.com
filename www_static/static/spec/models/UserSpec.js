define(function(require) {
  var User = require('models/User');

  describe('User', function() {

    it("exists", function(){
      expect(User).toBeDefined();
    });

    it("sets its path when supplied", function() {
      var user = new User({}, {path: 'a/path'});
      expect(user.path).toEqual('a/path');
    });

  });
});
