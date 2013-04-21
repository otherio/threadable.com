describeWidget("conversation_messages", function(){

  describe("appendMessage", function(){

    beforeEach(function() {
      this.form = this.widget.$('form');

      this.message = {
        as_html: '<div class="message" widget="message">fake message</div>'
      };

      this.messages = function(){
        return this.widget.$('li.with_message');
      }

      this.appendMessage = function(){
        this.form.trigger('ajax:success', [this.message, 200, {}]);
      }
    });

    it("should append the given message to the message list", function(){
      expect(this.messages().length).toEqual(2);

      this.appendMessage();

      expect(this.messages().length).toEqual(3);
      expect(this.messages().filter(':last').html()).toEqual(this.message.as_html);
    });

    it("refreshes the times", function() {
      var timeagoSpy = spyOn($.prototype, 'timeago');
      this.appendMessage();
      expect(timeagoSpy).toHaveBeenCalled();
    });

  });

  describe("onMessageBodyChange", function(){
    beforeEach(function(){
      this.textarea = this.widget.$('textarea')
      this.submit_button = this.widget.$('input[type=submit]');
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
