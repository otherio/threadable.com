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
      var tasks = new Tasks();
      tasks.fetch();
      mostRecentAjaxRequest().response(testResponses.tasks.success);
      expect(tasks.findBySlug('do-the-thing')).toEqual(jasmine.any(Task));
    });

    it("requests from the tasks path by default", function() {
      var tasks = new Tasks();
      expect(tasks.path).toEqual('/tasks');
    });

    it("requests from the project's tasks when a project is specified", function() {
      var tasks = new Tasks([], {project: {id: 1}});
      expect(tasks.path).toEqual('/projects/1/tasks');
    });

  });
});
