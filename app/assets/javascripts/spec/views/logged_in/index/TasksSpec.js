define(function(require) {
  var
    Tasks = require('models/Tasks'),
    TasksView = require('views/logged_in/index/Tasks')
    testResponses = require('spec/helpers/TestResponses');

  describe("Tasks View", function() {
    var tasks, view;
    beforeEach(function() {
      tasks = new Tasks();
      tasks.fetch();
      mostRecentAjaxRequest().response(testResponses.tasks.success);

      view = new TasksView({collection: tasks});
      view.render();
    });

    it("renders the tasks in the view", function() {
      expect(view.$el.text()).toContain(tasks.first().get('name'));
    });

    it("renders unfinished tasks without the done style", function() {
      expect(view.$('li:first-child')).not.toHaveClass('done');
    });

    it("renders finished tasks with the done style", function() {
      tasks.first().set('done', true); // assumes row render is bound to row model change event
      expect(view.$('li:first-child')).toHaveClass('done');
    });
  });
});
