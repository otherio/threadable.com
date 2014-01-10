Covered.ComposeController = Ember.ObjectController.extend({
  actions: {
    sendMessage: function() {
      var message = this.get('content');
      var conversation = message.get('conversation');
      if(conversation.get('isNew')) {
        conversation.set('subject', message.get('subject'));
        // conversation.set('organization', );
        //conversation.set('task', false);

      }
      conversation.save().then(function() {message.save();});
      this.transitionToRoute('index');
    }
  }
});
