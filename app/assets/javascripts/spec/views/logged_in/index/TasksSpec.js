define(function(require) {
  var
    Project = require('models/Project'),
    Tasks = require('models/Tasks'),
    Task = require('models/Task'),
    TasksView = require('views/logged_in/index/Tasks')
    testResponses = require('spec/helpers/TestResponses');

  describe("Tasks View", function() {
    var tasks, view;
    beforeEach(function() {
      tasks = new Tasks();
      tasks.fetch();
      mostRecentAjaxRequest().response(testResponses.tasks.success);

      view = new TasksView({model: new Project({id: 1}), collection: tasks});
      view.render();
    });

    describe("Item View", function() {
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

    describe("Main view", function() {
      it("presents a new task form", function() {
        expect(view.$('input[placeholder="New Task"]').length).toEqual(1);
      });

      describe("Creating tasks", function() {
        var $inputElement;
        beforeEach(function() {
          expect(tasks.length).toEqual(1);
          spyOn(Task.prototype, 'save');

          $inputElement = view.$('input[placeholder="New Task"]');
          $inputElement.val('this is a task');
          $inputElement.parent().submit();
        });

        it("adds a model to the collection", function() {
          expect(tasks.length).toEqual(2);
        });

        it("saves the model", function() {
          expect(Task.prototype.save).toHaveBeenCalled();
        });

        it("clears the input form", function() {
          expect($inputElement.val()).toEqual('');
        });

        it("sets the project", function() {
          expect(tasks.last().get('project_id')).toBeDefined();
        });

      });
    });
  });
});
