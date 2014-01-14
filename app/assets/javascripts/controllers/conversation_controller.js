Covered.ConversationController = Ember.ObjectController.extend({
  actions: {
    toggleComplete: function() {
      var conversation = this.get('content');
      conversation.set('done', !conversation.get('done'));
      conversation.saveRecord().then(function() {
        conversation.loadEvents(true);
      }.bind(this));
    }
  }
});
