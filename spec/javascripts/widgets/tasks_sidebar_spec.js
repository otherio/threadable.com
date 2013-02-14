describe("widgets/tasks_sidebar", function(){

  beforeEach(function(){
    loadFixture('widgets/tasks_sidebar');
    this.widget = Multify.Widget('tasks_sidebar');
    this.widget.initialize();
  });

  describe("adding a task", function(){

    it("should create a task and reload", function(){
      $('.tasks_sidebar input').val('build a sex robot');
      $('.tasks_sidebar form').submit();
      mostRecentAjaxRequest().response({
        status: 201,
        responseText: '<div class="tasks_sidebar">fake html returned from the server</div>'
      });
      expect( $('.tasks_sidebar').text() ).toEqual('fake html returned from the server');
    });

  });

});
