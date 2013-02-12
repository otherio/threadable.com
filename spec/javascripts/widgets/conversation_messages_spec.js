describe("widgets/conversation_messages", function(){

  beforeEach(function(){
    loadFixture('widgets/conversation_messages');
    this.widget = Multify.Widget('conversation_messages');
  });

  describe("appendMessage", function(){
    it("should append the given message to the message list", function(){
      var form = $('.conversation_messages form');
      var message = {
        as_html: '<div class="message"><p> From: Someone New </p> <p>Hi all.</p> </div>'
      };
      expect(messages().length).toEqual(2);
      this.widget.appendMessage(form, null, message, null, null);
      expect(messages().length).toEqual(3);
      expect(messages().filter(':last').html()).toEqual(message.as_html);
    });
  });

  describe("onMessageBodyChange", function(){
    beforeEach(function(){
      this.textarea = $('.conversation_messages textarea').val('');
      this.submit_button = $('.conversation_messages input[type=submit]');
    });

    context("when the message body is blank", function(){
      beforeEach(function(){
        this.textarea.val('');
      });
      it("should disable the send button", function(){
        this.widget.onMessageBodyChange(this.textarea);
        expect(this.submit_button.is(':disabled')).toBe(true);
      });
    });

    context("when the message body is present", function(){
      beforeEach(function(){
        this.textarea.val('hello friends.');
      });
      it("should enable the send button", function(){
        this.widget.onMessageBodyChange(this.textarea);
        expect(this.submit_button.is(':disabled')).toBe(false);
      });
    });


  });

  function messages(){
    return $('.conversation_messages .messages > *');
  }

});
