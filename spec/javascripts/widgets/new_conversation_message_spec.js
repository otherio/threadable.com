describeWidget("new_conversation_message", function(){

  contexts = [
    {
      description: 'for an existing conversation: ',
      selector: '.existing-conversation',
      formShouldBeRemote: true,
      makesTextAreaBigger: true
    },{
      description: 'for a new conversation: ',
      selector: '.new-conversation',
      shouldHaveSubject: true,
    }
  ];

  contexts.forEach(function(_context){

    context(_context.description, function(){

      var widget;

      function message_body_textarea() {
        return widget.node.find('.body_field').find('textarea, iframe').filter(':visible').first();
      }

      beforeEach(function() {
        widget = this.page.node.find(_context.selector).find(this.Widget.selector).widget();
      });


      if (_context.formShouldBeRemote){
        it("should be a remote form", function() {
          expect( widget.node.find('form').data('remote') ).toBe(true);
        });
      }else{
        it("should not be a remote form", function() {
          expect( widget.node.find('form').data('remote') ).not.toBe(true);
        });
      }


      describe("clicking on the message body", function() {

        it("adds html controls", function() {
          expect( message_body_textarea() ).toBeVisible();
          expect( message_body_textarea()[0].nodeName ).toEqual('TEXTAREA');

          runs(function(){
            message_body_textarea().click();
          });

          waits(200);

          runs(function(){
            expect( message_body_textarea() ).toBeVisible();
            expect( message_body_textarea()[0].nodeName ).toEqual('IFRAME');
          });
        });

        if (_context.makesTextAreaBigger){

          it("makes the textarea bigger", function() {
            waits(100);

            runs(function(){
              expect( message_body_textarea().height() ).toBeLessThan('56');
              message_body_textarea().click();
            });

            waits(100);

            runs(function(){
              expect( message_body_textarea().height() ).toBeGreaterThan('199');
            });
          });
        }

      });

      it("the enables and disables the send button depending on the presence of the subject and body fields", function() {
        runs(function() {
          message_body_textarea().click();
        });

        waits(1);

        runs(function() {
          expect( widget.isValid() ).toBe(false);
          expect( widget.send_button ).toBeDisabled();
          widget.subject_input.val('some subject');
          widget.message_body.editor.composer.setValue('some body');
          expect( widget.isValid() ).toBe(true);
          widget.message_body_textarea.change();
        });

        waits(1);

        runs(function() {
          expect( widget.send_button ).not.toBeDisabled();
        });
      });

      describe("clicking send", function(){

        var formSubmitted = false;

        beforeEach(function() {
          this.form = widget.node.find('form')[0];

          $(this.form).on('submit', function(event){
            formSubmitted = true;
            event.preventDefault();
          });

          runs(function() {
            message_body_textarea().click();
          });
          waits(1);
        });

        context("when the form is invalid", function(){

          beforeEach(function() {
            runs(function() {
              widget.message_body.editor.composer.setValue('');
              widget.subject_input.val('');
              widget.message_body_textarea.change();
              expect( widget.isValid() ).toBe(false);
            });
            waits(1);
          });

          it("should show a flash notice and not submit", function(){
            runs(function() {
              expect( widget.send_button ).toBeDisabled();
              widget.send_button.click();
              expect(formSubmitted).toBe(false);
            });
          });

        });

        context("when the form is valid", function(){

          beforeEach(function() {
            runs(function() {
              widget.message_body.editor.composer.setValue('a body');
              widget.subject_input.val('a subject');
              widget.message_body_textarea.change();
              expect( widget.isValid() ).toBe(true);
            });
            waits(1);
          });

          it("should submit", function(){
            runs(function() {
              expect( widget.send_button ).not.toBeDisabled();
              widget.send_button.click();
              expect(formSubmitted).toBe(true);
            });
          });

        });

      });

    });

  });

});
