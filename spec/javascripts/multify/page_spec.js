describe("Multify.Page", function(){

  var page, env;

  beforeEach(function(){
    env = {
      page_name: 'example/page/name',
      current_project:      {current_project:true},
      current_conversation: {current_conversation:true},
      current_task:         {current_task:true},
      current_task_doers:   {current_task_doers:true},
      current_user:         {current_user:true},
    };

    page = new Multify.Page(env);
  });

  it("should assign page name", function(){
    expect(page.name).toEqual('example/page/name');
  });

  it("should assign current_{x} properties", function(){
    expect(page.name).toEqual('example/page/name');

    expect(page.current_project     ).toEqual(page.current_project)
    expect(page.current_conversation).toEqual(page.current_conversation)
    expect(page.current_task        ).toEqual(page.current_task)
    expect(page.current_task_doers  ).toEqual(page.current_task_doers)
    expect(page.current_user        ).toEqual(page.current_user)
  });

  describe('domready handling', function(){
    beforeEach(function() {
      page.trigger('domready');
    });

    it("should find the .page element", function() {
      expect(page.node).toEqual($('.page'));
    });
  });

});
