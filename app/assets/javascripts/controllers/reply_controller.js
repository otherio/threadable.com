Covered.ReplyController = Ember.ObjectController.extend({
  needs: ['conversation', 'organization'],

  error: null,

  actions: {
    sendMessage: function() {
      this.set('error', null);
      var organizationSlug = this.get('controllers.organization').get('content').get('slug');
      var conversation = this.get('controllers.conversation');

      var message = this.get('content');

      message.setProperties({
        organizationSlug: organizationSlug,
        conversationId:   conversation.get('id'),
        body:             this.get('body')
      });

      message.saveRecord().then(success.bind(this), error.bind(this));

      function success(response) {
        conversation.get('messages').pushObject(this.get('content'));
        this.set('content', Covered.Message.create({}));
      }

      function error(response){
        var error = response && response.error || 'an unknown error occurred';
        this.set('error', error);
      }
    }
  }
});
