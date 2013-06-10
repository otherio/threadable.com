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

      it("resets the form after sending", function() {
        expect(this.submit_button.is(':disabled')).toBe(true);
        this.widget.$('textarea').click();
        expect(this.submit_button.is(':disabled')).toBe(false);
        this.submit_button.click();
        mostRecentAjaxRequest().response({status: 200, responseText: '{}'});
        expect(this.submit_button.is(':disabled')).toBe(true);
        expect(this.widget.$('ul.wysihtml5-toolbar').html()).toBe(undefined);
        expect(this.widget.$('iframe.wysihtml5-sandbox').html()).toBe(undefined);
        expect(this.widget.$('textarea').css('height')).toEqual('40px');
        expect(this.widget.$('textarea')).toBeVisible();
      });
    });
  });

  describe("setupNewMessageInput", function() {
    beforeEach(function() {
      this.textarea = this.widget.$('textarea');
    });

    it("adds html controls", function() {
      var wysispy = spyOn($.prototype, 'wysihtml5');
      this.textarea.click();
      expect(wysispy).toHaveBeenCalled();
    });

    it("makes the textarea bigger", function() {
      this.textarea.click();
      expect(this.textarea.css('height')).toEqual('200px');
    });

    it("enables the send button", function() {
      this.textarea.click();
      expect(this.submit_button.is(':disabled')).toBe(false);
    });
  });

});
