define(function(require) {
  var
    Projects = require('models/Projects'),
    Project = require('models/Project'),
    testResponses = require('spec/helpers/TestResponses');

  describe('Projects', function() {
    it("exists", function(){
      expect(Projects).toBeDefined();
    });

    it("finds by slug", function() {
      var projects = new Projects();
      projects.fetch();
      mostRecentAjaxRequest().response(testResponses.projects.success);
      expect(projects.findBySlug('project-1')).toEqual(jasmine.any(Project));
    });
  });
});
