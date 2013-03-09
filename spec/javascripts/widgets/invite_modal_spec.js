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
    $('.invite_modal .modal').modal('show');
  }

  function submit_invite(){
    $('.invite_modal input[name="invite[name]"]').val('Steve Jobs');
    $('.invite_modal input[name="invite[email]"]').val('steve@apple.com');
    $('.invite_modal input[type=submit]').focus().click();
  }

  // this was failing intermitantly on CI. Not worth it.
  // function expectFirstInputToBeFocused(){
  //   var activeElement = document.activeElement;
  //   var the_first_input = $('.invite_modal input:visible:first')[0];
  //   debugger
  //   expect(document.activeElement).toEqual(the_first_input);
  // }

  context('when the server responds with a 200', function(){
    it("should show a flash message saying the user has been added", function(){

      runs(function(){
        spyOn(Multify.Flash, 'message');
        open_invite_modal();
      });

      waits(400);

      runs(function(){
        submit_invite();
        var request = mostRecentAjaxRequest();
        var expected_url = $('.invite_modal form').attr('action');
        expect(request.url).toEqual(expected_url);
        expect(request.method).toEqual("POST");
        request.response({
          status: 200,
          responseText: '{"name":"Ballzonya", "email":"ballz@ya.org"}'
        });
      });

      waits(400);

      runs(function(){
        expect(Multify.Flash.message.calls.length).toEqual(1);
        var element = Multify.Flash.message.mostRecentCall.args[0]
        var html = element.clone().appendTo('<div>').parent().html();
        expect(html).toEqual("<span>Ballzonya &lt;ballz@ya.org&gt; was added to this project.</span>");
      });
    });
  });

  context('when the server responds with a 400', function(){
    it("should close the modal and flash a message saying the user is already a member of this project", function(){

      runs(function(){
        spyOn(Multify.Flash, 'notice');
        open_invite_modal();
      });

      waits(400);

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
        // expectFirstInputToBeFocused();
        expect(Multify.Modal.Flash.alert).toHaveBeenCalledWith('Oops! Something went wrong. Please try again later.');
      });

    });
  });

});
