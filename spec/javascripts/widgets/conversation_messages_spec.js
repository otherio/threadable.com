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
  });

});
