describe("widgets/task_metadata", function(){

  beforeEach(function(){
    loadFixture('widgets/task_metadata');
    this.widget = Multify.Widget('task_metadata');
  });

  describe("getCurrentProjectMembers", function() {
    var spy;
    beforeEach(function() {
      delete this.widget.users;  // this is messy, but avoids test pollution
      ENV = {currentProject: {slug: 'project-slug'} };
      Multify.initialize();  // reset current project
      jasmine.Ajax.useMock();
      spy = jasmine.createSpy();
    });

    it("gets the current project members", function() {
      this.widget.getCurrentProjectMembers(spy);
      mostRecentAjaxRequest().response({status: 200, responseText: '[{"name": "foo", "email": "foo@example.com"}]'});
      expect(spy).toHaveBeenCalledWith([ { name: 'foo', email: 'foo@example.com' } ]);
    });

    it("fetches from the right url", function() {
      this.widget.getCurrentProjectMembers(spy);
      expect(mostRecentAjaxRequest().url).toEqual('/project-slug/members');
    });

    it("only gets the project members once", function() {
      clearAjaxRequests();
      this.widget.getCurrentProjectMembers(spy);
      expect(ajaxRequests.length).toEqual(1);
    });
  });


});
