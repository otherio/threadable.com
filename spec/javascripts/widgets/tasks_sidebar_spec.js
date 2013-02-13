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
        responseText: ''
      });
      mostRecentAjaxRequest().response({
        status: 201,
        responseText: '{"as_html": "the fake html we returned from the server"}'
      });
      expect( $('body').text() ).toMatch(/the fake html we returned from the server/);
    });

  });

});
