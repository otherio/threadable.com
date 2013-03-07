describe("widgets/invite_modal", function(){

  beforeEach(function(){
    loadFixture('widgets/invite_modal');
    this.widget = Multify.Widget('invite_modal');
    this.widget.initialize();
  });

  afterEach(function(){
    $('.modal-backdrop').remove();
  });

  function open_invite_modal(){
    runs(function(){
      $('.invite_modal .modal').modal('show');
    });

    waits(400);

    runs(function(){
      expectFirstInputToBeFocused();
    });
  }

  function submit_invite(){
    $('.invite_modal input[name="invite[name]"]').val('Steve Jobs');
    $('.invite_modal input[name="invite[email]"]').val('steve@apple.com');
    $('.invite_modal input[type=submit]').focus().click();
  }

  function expectFirstInputToBeFocused(){
    var the_first_input = $('.invite_modal input:visible:first')[0];
    expect(document.activeElement).toNotBe(undefined);
    expect(document.activeElement).toEqual(the_first_input);
  }

  context('when the server responds with a 200', function(){
    it("should show a flash message saying the user has been added", function(){
      spyOn(Multify.Flash, 'message');

      open_invite_modal();

      runs(function(){
        submit_invite();
        mostRecentAjaxRequest().response({
          status: 200,
          responseText: '{"name":"Ballzonya", "email":"ballz@ya.org"}'
        });
      });

      waits(400);

      runs(function(){
        var content = Multify.Flash.message.mostRecentCall.args[0][0]
        expect(content.nodeName).toEqual('SPAN');
        expect(content.textContent).toEqual("Ballzonya <ballz@ya.org> was added to this project.");
      });
    });
  });

  context('when the server responds with a 400', function(){
    it("should close the modal and flash a message saying the user is already a member of this project", function(){
      spyOn(Multify.Flash, 'notice');

      open_invite_modal();

      runs(function(){
        submit_invite();

        mostRecentAjaxRequest().response({
          status: 400,
          responseText: ''
        });
      });

      waits(400);

      runs(function(){
        expect($('.modal:visible').length).toBe(0);
        expect(Multify.Flash.notice).toHaveBeenCalledWith('That user is already a member of this project.');
      });

    });
  });

  context('when the server responds with a 500', function(){
    it("should close the modal and flash a message saying the user is already a member of this project", function(){
      spyOn(Multify.Modal.Flash, 'alert');

      open_invite_modal();
      runs(function(){
        submit_invite();

        mostRecentAjaxRequest().response({
          status: 500,
          responseText: ''
        });
      });

      waits(400);

      runs(function(){
        expect($('.modal:visible').length).toBe(1);
        expectFirstInputToBeFocused();
        expect(Multify.Modal.Flash.alert).toHaveBeenCalledWith('Oops! Something went wrong. Please try again later.');
      });

    });
  });

});
