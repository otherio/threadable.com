define(function(require) {
  var User = require('models/User');

  describe('User', function() {

    it("exists", function(){
      expect(User).toBeDefined();
    });

  });
});
