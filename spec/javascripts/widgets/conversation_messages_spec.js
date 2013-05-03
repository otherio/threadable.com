describeWidget("conversation_messages", function(){
  beforeEach(function() {
    this.submit_button = this.widget.$('input[type=submit]');
  });

  describe("appendMessage", function(){

    describe("on ajax success", function() {
      beforeEach(function() {
        this.form = this.widget.$('form');

        this.message = {
          as_html: '<div class="message" widget="message">fake message</div>'
        };

        this.messages = function(){
          return this.widget.$('li.with_message');
        }

        this.triggerSuccess = function(){
          this.form.trigger('ajax:success', [this.message, 200, {}]);
        }
      });

      it("should append the given message to the message list", function(){
        expect(this.messages().length).toEqual(2);

        this.triggerSuccess();

        expect(this.messages().length).toEqual(3);
        expect(this.messages().filter(':last').html()).toEqual(this.message.as_html);
      });

      it("refreshes the times", function() {
        var timeagoSpy = spyOn($.prototype, 'timeago');
        this.triggerSuccess();
        expect(timeagoSpy).toHaveBeenCalled();
      });
    });

    it("disables the send button after sending", function() {
      expect(this.submit_button.is(':disabled')).toBe(true);
      this.widget.$('textarea').val('this is a message').trigger('keyup');
      expect(this.submit_button.is(':disabled')).toBe(false);
      this.submit_button.click();
      mostRecentAjaxRequest().response({status: 200, responseText: '{}'});
      expect(this.submit_button.is(':disabled')).toBe(true);
    });
  });

  describe("onMessageBodyChange", function(){
    beforeEach(function(){
      this.textarea = this.widget.$('textarea')
    });

    context("when the message body is blank", function(){
      beforeEach(function(){
        this.textarea.val('');
      });
      it("should disable the send button", function(){
        this.textarea.trigger('keyup');
        expect(this.submit_button.is(':disabled')).toBe(true);
      });
    });

    context("when the message body is present", function(){
      beforeEach(function(){
        this.textarea.val('hello friends.');
      });
      it("should enable the send button", function(){
        this.textarea.trigger('keyup');
        expect(this.submit_button.is(':disabled')).toBe(false);
      });
    });


  });

});
