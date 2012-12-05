define(function(require) {
  var Task = require('models/Task');

  describe('Task', function() {

    it("exists", function(){
      expect(Task).toBeDefined();
    });

  });
});
