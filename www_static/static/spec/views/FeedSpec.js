define(function(require) {
  var
    Feed = require('views/logged_in/index/Feed');

  describe("Feed", function() {
    var view, model;

    beforeEach(function() {
      model = new Backbone.Model();
      view = new Feed({
        model: model
      });
    });

    it("has an itemview", function() {
      expect(view.itemView).toEqual(jasmine.any(Function));
    });

    it("has an emptyview", function() {
      expect(view.emptyView).toEqual(jasmine.any(Function));
    });
  });
});
