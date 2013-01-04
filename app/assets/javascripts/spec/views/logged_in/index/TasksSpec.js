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
        expect(view.$('tr:first-child')).not.toHaveClass('done');
      });

      it("renders finished tasks with the done style", function() {
        tasks.first().set('done', true); // assumes row render is bound to row model change event
        expect(view.$('tr:first-child')).toHaveClass('done');
      });

      it("has a complete button", function() {
        expect(view.$('tr:first-child > td.task-status').length).toBeGreaterThan(0);
      });

      it("marks the task done when the complete button is pushed", function() {
        clearAjaxRequests();
        view.$('tr:first-child > td.task-status').click();
        expect(view.$('tr:first-child')).toHaveClass('done');
        expect(mostRecentAjaxRequest().method).toEqual('PUT');
      });
    });

    describe("Main Tasks CompositeView", function() {
      it("presents a new task form", function() {
        expect(view.$('input[placeholder="New Task"]').length).toEqual(1);
      });

      describe("Creating tasks", function() {
        var $inputElement;
        beforeEach(function() {
          expect(tasks.length).toEqual(1);
          spyOn(Task.prototype, 'save');

          $inputElement = view.$('input.new-task');
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


      describe("filtering controls", function() {
        it("toggles completed task display", function() {
          tasks.first().set('done', true);
          view.$('.done-toggle[data-show="unfinished"]').click();
          expect(view.$('.done').length).toEqual(0);
          view.$('.done-toggle[data-show="all"]').click();
          expect(view.$('.done').length).toEqual(1);
        });

        it("defaults to all", function() {
          expect(view.$('.done-toggle[data-show="all"]')).toHaveClass('active');
        });

        it("hides completed tasks immediately", function() {
          view.$('.done-toggle[data-show="unfinished"]').click();
          expect(view.$('.task-status').length).toEqual(1);  // there's a task showing (from TestResponses)
          view.$('td.task-status').click();  // click the done button
          expect(view.$('.task-status').length).toEqual(0);  // no tasks showing
        });
      });
    });
  });
});
