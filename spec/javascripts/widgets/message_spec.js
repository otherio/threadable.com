describeWidget("message", function(){

  describe("initialize", function(){

    // it("binds shareworthy and knowledge actions", function() {
    //   this.widget.$('a.shareworthy').first().click();
    //   var request = mostRecentAjaxRequest();
    //   expect(request.url).toMatch(/messages/);
    //   expect(request.method).toEqual('PUT');
    //   expect(request.params).toMatch(/shareworthy/);

    //   this.widget.$('a.knowledge').first().click();
    //   request = mostRecentAjaxRequest();
    //   expect(request.params).toMatch(/knowledge/);
    // });

    it("binds the show-quoted-text button", function() {
      this.widget.$('.show-quoted-text').first().click();
      expect(this.widget.$('.message-body')).toHaveClass('show-full');
    });

  });

});
