describeWidget("tasks_sidebar", function(){

  beforeEach(function(){
    this.expectTheVisibleTabToBe = function(tab){
      expect(this.widget.node.attr('showing')).toEqual(tab);
      expect(this.widget.node.find('> .conversations').is(':visible')).toBe(tab == 'conversations');
      expect(this.widget.node.find('> .all_tasks'    ).is(':visible')).toBe(tab == 'all_tasks');
      expect(this.widget.node.find('> .my_tasks'     ).is(':visible')).toBe(tab == 'my_tasks');
    };
  });


  describe("tabs", function(){
    context("clicking on the tabs buttons", function() {
      it("should be able to switch tabs", function(){
        this.page.node.find('button.conversations').click();
        this.expectTheVisibleTabToBe('conversations');
        this.page.node.find('button.all_tasks').click();
        this.expectTheVisibleTabToBe('all_tasks');
        this.page.node.find('button.my_tasks').click();
        this.expectTheVisibleTabToBe('my_tasks');
      });
    });

    describe("#showTab", function() {
      it("should show the given tab name and default to all_tasks", function() {
        this.widget.showTab();
        this.expectTheVisibleTabToBe('all_tasks');
        this.widget.showTab('conversations');
        this.expectTheVisibleTabToBe('conversations');
        this.widget.showTab('all_tasks');
        this.expectTheVisibleTabToBe('all_tasks');
        this.widget.showTab('my_tasks');
        this.expectTheVisibleTabToBe('my_tasks');
      });
    });

  });

  describe("creating a task", function() {
    it("should post the new task and replace it's self with the ajax response", function() {
      this.widget.node.find('input').val('buy more milk');
      this.widget.node.find('form').submit();
      var request = mostRecentAjaxRequest();
      expect(request.method).toEqual('POST');
      expect(request.params).toEqual("task%5Bsubject%5D=buy+more+milk");
      expect((/\/tasks$/).test(request.url)).toBe(true)

      request.response({
        status: 200,
        responseText: '<div widget="'+Widget.classname+'">some html</div>'
      });

      expect(this.page.node.children().length).toEqual(1);
      expect(this.page.node.children().text()).toEqual('some html');
    });

  });

});
