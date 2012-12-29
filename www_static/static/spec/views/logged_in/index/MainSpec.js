define(function(require) {
  var
    Backbone = require('backbone'),
    Main = require('views/logged_in/index/Main'),
    Tasks = require('views/logged_in/index/Tasks'),
    Members = require('views/logged_in/index/Members'),
    testResponses = require('spec/helpers/TestResponses'),
    Projects = require('models/Projects');

  describe("Main View", function() {
    var view;
    beforeEach(function() {
      var projects = new Projects();
      projects.fetch();
      mostRecentAjaxRequest().response(testResponses.projects.success);
      view = new Main({model: projects.first()});

      spyOn(view.tabContent, 'show');
      view.render();
    });

    it("defaults to the tasks view", function() {
      expect(view.tabContent.show).toHaveBeenCalledWith(jasmine.any(Tasks));
    });

    it("sets the active tab", function() {
      expect(view.$('.tabs > li.tasks')).toHaveClass('active');
    });

    it("switches to the members view when the members tab is clicked", function() {
      view.tabContent.show.reset();
      view.$('.tabs > li.members > a').click();
      expect(view.tabContent.show).toHaveBeenCalledWith(jasmine.any(Members));
      expect(view.$('.tabs > li.tasks')).not.toHaveClass('active');
      expect(view.$('.tabs > li.members')).toHaveClass('active');
    });

    it("navigates to the proper url when the members tab is clicked", function() {
      expect(Backbone.history.navigate).toHaveBeenCalledWith('/project-1/tasks');
    });

  });
});
