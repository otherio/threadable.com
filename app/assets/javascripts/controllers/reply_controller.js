Covered.ReplyController = Ember.ObjectController.extend({
  needs: ['conversation', 'organization'],

  message: Ember.computed.alias('model'),

  error: null,

  actions: {
    reset: function() {
      this.set('error', null);
      this.set('message.body', null);
    },
    sendMessage: function() {
      this.set('error', null);
      var organizationSlug = this.get('controllers.organization').get('content').get('slug');
      var conversation = this.get('controllers.conversation.model');

      var message = this.get('message');

      message.setProperties({
        organizationSlug: organizationSlug,
        conversationId:   conversation.get('id'),
        body:             this.get('body')
      });

      message.saveRecord().then(onSuccess.bind(this), onError.bind(this));

      function onSuccess(response) {
        conversation.deserialize(response.message.conversation);

        var message = this.get('content');
        var event = Covered.Event.create({
          id:        'message-' + message.get('id'),
          eventType: 'created_message',
          createdAt: message.get('sentAt'),
          message:   message,
        });

        conversation.get('events').pushObject(event);
        this.set('content', Covered.Message.create({}));
      }

      function onError(response){
        var error = response && response.error || 'an unknown error occurred';
        this.set('error', error);
      }
    }
  }
});
