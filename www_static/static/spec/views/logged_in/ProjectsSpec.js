define(function(require) {
  var
    Projects = require('views/logged_in/index/Projects');

  describe("Projects", function() {
    var view;

    beforeEach(function() {
      view = new Projects();
    });

    it("has a list region", function() {
      expect(view.regions.list).toBeDefined();
    });

    // more tests here

  });
});
