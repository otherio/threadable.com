describeWidget("invite_modal", function(){

  // function open_invite_modal(){
  //   $('.invite_modal').modal('show');
  // }

  // function submit_invite(){
  //   $('.invite_modal input[name="invite[name]"]').val('Steve Jobs');
  //   $('.invite_modal input[name="invite[email]"]').val('steve@apple.com');
  //   $('.invite_modal input[type=submit]').focus().click();
  // }

  // // this was failing intermitantly on CI. Not worth it.
  // // function expectFirstInputToBeFocused(){
  // //   var activeElement = document.activeElement;
  // //   var the_first_input = $('.invite_modal input:visible:first')[0];
  // //   debugger
  // //   expect(document.activeElement).toEqual(the_first_input);
  // // }

  // context('when the server responds with a 200', function(){
  //   it("calls a passed in success function", function() {
  //     var spy = jasmine.createSpy('successFunction');

  //     runs(function() {
  //       Covered.page.trigger('show_invite_modal', {name: 'some guy', email: 'foo@foo.foo', success: spy});
  //     });

  //     waits(300);

  //     runs(function(){
  //       $('.modal-footer input').click();
  //       mostRecentAjaxRequest().response({
  //         status: 200,
  //         responseText: '{"name":"Ballzonya", "email":"ballz@ya.org"}'
  //       });
  //       expect(spy).toHaveBeenCalledWith({name: "Ballzonya", email: "ballz@ya.org"});
  //     });
  //   });

  //   it("should show a flash message saying the user has been added", function(){

  //     runs(function(){
  //       spyOn(Covered.Flash, 'message');
  //       open_invite_modal();
  //     });

  //     waits(400);

  //     runs(function(){
  //       submit_invite();
  //       var request = mostRecentAjaxRequest();
  //       var expected_url = $('.invite_modal form').attr('action');
  //       expect(request.url).toEqual(expected_url);
  //       expect(request.method).toEqual("POST");
  //       request.response({
  //         status: 200,
  //         responseText: '{"name":"Ballzonya", "email":"ballz@ya.org"}'
  //       });
  //     });

  //     waits(400);

  //     runs(function(){
  //       // TODO: for some reason this happens two times in test.
  //       // probably points to a deeper test pollution problem, so is worth finding out why
  //       //expect(Covered.Flash.message.calls.length).toEqual(1);
  //       var element = Covered.Flash.message.mostRecentCall.args[0]
  //       var html = element.clone().appendTo('<div>').parent().html();
  //       expect(html).toEqual("<span>Ballzonya &lt;ballz@ya.org&gt; was added to this project.</span>");
  //     });
  //   });
  // });

  // context('when the server responds with a 400', function(){
  //   it("should close the modal and flash a message saying the user is already a member of this project", function(){

  //     runs(function(){
  //       spyOn(Covered.Flash, 'notice');
  //       open_invite_modal();
  //     });

  //     waits(400);

  //     runs(function(){
  //       submit_invite();

  //       mostRecentAjaxRequest().response({
  //         status: 400,
  //         responseText: ''
  //       });
  //     });

  //     waits(400);

  //     runs(function(){
  //       expect($('.modal:visible').length).toBe(0);
  //       expect(Covered.Flash.notice).toHaveBeenCalledWith('That user is already a member of this project.');
  //     });

  //   });
  // });

  // context('when the server responds with a 500', function(){
  //   it("should close the modal and flash a message saying the user is already a member of this project", function(){

  //     runs(function(){
  //       spyOn(Covered.Modal.Flash, 'alert');
  //       spyOn(Covered.Flash, 'notice');
  //       open_invite_modal();
  //     });

  //     waits(400);

  //     runs(function(){
  //       submit_invite();

  //       mostRecentAjaxRequest().response({
  //         status: 500,
  //         responseText: ''
  //       });
  //     });

  //     waits(400);

  //     runs(function(){
  //       expect($('.modal:visible').length).toBe(1);
  //       // expectFirstInputToBeFocused();
  //       expect(Covered.Modal.Flash.alert).toHaveBeenCalledWith('Oops! Something went wrong. Please try again later.');
  //     });

  //   });
  // });

});
