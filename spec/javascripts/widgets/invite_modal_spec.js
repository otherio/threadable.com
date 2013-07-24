describeWidget("invite_modal", function(){

  beforeEach(function() {
    this.expectModalToBeVisible = function() {
      expect( this.widget.node.is(':visible') ).toBe(true);
    };
    this.expectModalNotToBeVisible = function() {
      expect( this.widget.node.is(':visible') ).not.toBe(true);
    };
  });

  function showModal(callback) {
    runs(function() {
      expect( this.widget.node.is(':visible') ).toBe(false);
      this.widget.show();
    });
    waits(300); // bootstrap animation time
    if (callback) runs(callback);
  }


  describe("initialize", function(){
    it("should find the expected elements", function(){
      expect( this.widget.flash       ).toBeA(Covered.Flash);
      expect( this.widget.form[0]     ).toBe( this.page.$('form')[0] );
      expect( this.widget.name_input  ).toBe( this.page.$('input[name="invite[name]"]')[0] );
      expect( this.widget.email_input ).toBe( this.page.$('input[name="invite[email]"]')[0] );
    });
  });

  describe("show", function(){
    it("should show the invite modal", function() {
      showModal(function() {
        this.expectModalToBeVisible();
        expect( $(':focus')[0] ).toBe( this.widget.name_input[0] );
      });
    });
  });

  describe("hide", function(){
    it("should hide and reset the invite modal", function() {
      showModal();
      runs(function() {
        this.expectModalToBeVisible();
        expect( $(':focus')[0] ).toBe( this.widget.name_input[0] );
        this.widget.hide();
      });
      waits(300); // bootstrap animation time
      runs(function() {
        expect( this.widget.node.is(':visible') ).toBe(false);
        expect( $(':focus')[0] ).not.toBe( this.widget.name_input[0] );
      });
    });
  });

  describe("focus", function(){
    it("should focus the first visible input", function() {
      showModal(function() {
        $(':input:last').focus();
        expect( $(':focus')[0] ).not.toBe( this.widget.name_input[0] );
        this.widget.focus();
        expect( $(':focus')[0] ).toBe( this.widget.name_input[0] );
      });
    });
  });

  describe("reset", function(){
    it("should empty the flash, reset the form and focus the first visible element", function() {
      showModal(function() {
        this.widget.name_input.val('some value');
        this.widget.email_input.val('some value');
        $(':input:last').focus();
        this.widget.flash.notice('asdsa');

        expect( this.widget.name_input.val()                 ).not.toEqual('');
        expect( this.widget.email_input.val()                ).not.toEqual('');
        expect( $(':focus')[0]                               ).not.toBe( this.widget.name_input[0] );
        expect( this.widget.flash_messages.children().length ).not.toBe(0);

        this.widget.reset();

        expect( this.widget.name_input.val()                 ).toEqual('');
        expect( this.widget.email_input.val()                ).toEqual('');
        expect( $(':focus')[0]                               ).toBe( this.widget.name_input[0] );
        expect( this.widget.flash_messages.children().length ).toBe(0);
      });
    });
  });

  describe("triggering show_invite_modal on page", function(){

    it("should show the invite modal using the given options", function() {
      var successCalled = false;
      runs(function() {
        this.page.trigger('show_invite_modal', {
          name: 'Steve Jobs',
          email: 'steve@apple.com',
          success: function(){ successCalled = true; }
        });
      });
      waits(300);
      runs(function() {
        this.expectModalToBeVisible();
        expect( this.widget.name_input.val()  ).toEqual('Steve Jobs');
        expect( this.widget.email_input.val() ).toEqual('steve@apple.com');
        this.widget.form.trigger('ajax:success', {});
      });
      waits(300);
      runs(function() {
        this.expectModalNotToBeVisible();
        expect(successCalled).toBe(true);
      });
    });
  });

  context("when the `shown' event is triggered", function(){
    it("should call focus on the widget", function() {
      var focus = spyOn(this.widget,'focus');
      this.widget.trigger('shown');
      expect(focus).toHaveBeenCalled()
    });
  });

  context("when the `ajax:send' event is triggered on the form", function(){
    it("should call focus on the widget", function() {
      var disable = spyOn(this.widget,'disable');
      var empty   = spyOn(this.widget.flash,'empty');
      this.widget.form.trigger('ajax:send');
      expect(disable).toHaveBeenCalled();
      expect(empty).toHaveBeenCalled();
    });
  });

  context("when the `ajax:success' event is triggered on the form", function(){
    it("should call focus on the widget", function() {
      var hide  = spyOn(this.widget,'hide').andReturn(this.widget);
      var reset = spyOn(this.widget,'reset').andReturn(this.widget);
      var flash_message = spyOn(this.page.flash,'message');
      user = {
        name: 'Steve Jobs',
        email: 'steve@apple.com',
      };
      this.widget.form.trigger('ajax:success', [user, "ok", {}]);
      expect(hide).toHaveBeenCalled();
      expect(reset).toHaveBeenCalled();
      expect(flash_message).toHaveBeenCalledWith('Steve Jobs <steve@apple.com> was added to this project.');
    });
  });

  context("when the `ajax:error' event is triggered on the form", function(){

    it("should call focus on the widget", function() {
      var enable = spyOn(this.widget,'enable');
      var flash_alert = spyOn(this.widget.flash,'alert');
      this.widget.form.trigger('ajax:error', [{}, "ok", {}]);
      expect(enable).toHaveBeenCalled();
      expect(flash_alert).toHaveBeenCalledWith('Oops! Something went wrong. Please try again later.');
    });

    context("when the status code is 400", function() {
      it("should call focus on the widget", function() {
        var enable = spyOn(this.widget,'enable');
        var flash_notice = spyOn(this.widget.flash,'notice');
        this.widget.form.trigger('ajax:error', [{status:400}, "not found", {}]);
        expect(enable).toHaveBeenCalled();
        expect(flash_notice).toHaveBeenCalledWith('That user is already a member of this project.');
      });
    });
  });

});
