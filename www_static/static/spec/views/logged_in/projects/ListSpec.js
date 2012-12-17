define(function(require) {
  var
    Marionette = require('marionette'),
    List = require('views/logged_in/index/projects/List')
    Projects = require('models/Projects'),
    testResponses = require('spec/helpers/TestResponses');

  describe("Projects List", function() {
    var view, collection;

    beforeEach(function() {
      collection = new Projects();
      collection.fetch();
      var request = mostRecentAjaxRequest();
      request.response(testResponses.projects.success);

      view = new List({
        collection: collection,
        selectedProject: 'project-1' // from testresponses
      });
    });

    it("has an itemview", function() {
      expect(view.itemView).toEqual(jasmine.any(Function));
    });

    it("has an emptyview", function() {
      expect(view.emptyView).toEqual(jasmine.any(Function));
    });

    it("highlights the selected project", function() {
      view.render();
      expect(view.$('li:first-child')).toHaveClass('active');
      expect(view.$('li.active').length).toEqual(1); // there can be only one!
    });

  });

});
