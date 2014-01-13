Covered.ReplyController = Ember.ObjectController.extend({
  needs: ['conversation', 'organization'],

  actions: {
    sendMessage: function() {
      var organizationSlug = this.get('controllers.organization').get('content').get('slug');
      var conversation = this.get('controllers.conversation');

      var message = this.get('content');

      message.setProperties({
        organizationId: organizationSlug,
        conversationId: conversation.get('slug'),
        body:           this.get('body')
      });

      message.saveRecord().then(function(response) {
        conversation.get('messages').pushObject(this.get('content'));
        this.set('content', new Covered.Message({}));
      }.bind(this), function(response){
        console.log('we would handle an error in saving the message here: ', response);
      });
    }
  }
});
