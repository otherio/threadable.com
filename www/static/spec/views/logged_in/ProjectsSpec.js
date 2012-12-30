define(function(require) {
  var
    Projects = require('views/logged_in/index/Projects'),
    Project  = require('models/Project');

  describe("Projects", function() {
    var view;

    beforeEach(function() {
      view = new Projects();
    });

    it("has a list region", function() {
      expect(view.regions.list).toBeDefined();
    });

    describe("#onRender", function() {

    });

    describe("#selectProject", function() {

    });

    describe("#createNewProject", function() {

      // TODO: fuuuuuuuck this test
      it("does everything exactafuckingluetly as this test demands", function() {
        var fakeEvent, element, fakeInput, fakeCollection

        fakeEvent = jasmine.createSpyObj('fakeEvent', ['preventDefault']);

        fakeInput = jasmine.createSpyObj('fakeInput', ['val','attr']);
        fakeInput.val.andReturn('fake project name');

        spyOn($.fn,'find').andReturn(fakeInput);

        fakeCollection = jasmine.createSpyObj('fakeCollection', ['add']);
        view.list.currentView = { collection: fakeCollection};
        spyOn(Project.prototype, "save");

        view.createNewProject(fakeEvent);

        expect($.fn.find).toHaveBeenCalledWith('input');
        expect(fakeInput.val).toHaveBeenCalledWith();
        expect(fakeInput.attr).toHaveBeenCalledWith('disabled', true);
        expect(Project.prototype.save.calls[0].args[0]).toBe(null);

        fakeInput.val.andReturn(fakeInput);
        App.router = jasmine.createSpyObj("fakeRouter", ['navigate']);

        Project.prototype.save.calls[0].args[1].success();
        expect(fakeInput.val).toHaveBeenCalledWith('');
        expect(fakeInput.attr).toHaveBeenCalledWith('disabled', false);
        expect(view.list.currentView.collection.add).toHaveBeenCalled();
        expect(App.router.navigate).toHaveBeenCalledWith('/undefined', {trigger:true});
      });

    });

  });
});
