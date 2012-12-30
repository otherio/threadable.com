define(function(require) {
  var
    Tasks = require('models/Tasks'),
    Task = require('models/Task'),
    testResponses = require('spec/helpers/TestResponses');

  describe('Tasks', function() {

    it("exists", function(){
      expect(Tasks).toBeDefined();
    });

    it("finds by slug", function() {
      var tasks = new Tasks([], {project_id: 1});
      tasks.fetch();
      debugger
      mostRecentAjaxRequest().response(testResponses.tasks.success);
      expect(tasks.findBySlug('project-1')).toEqual(jasmine.any(Task));
    });

  });
});
