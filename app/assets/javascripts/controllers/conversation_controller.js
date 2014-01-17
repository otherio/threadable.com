Covered.ConversationController = Ember.ObjectController.extend({
  needs: ['doerSelector'],

  showDoerSelector: false,

  actions: {
    toggleDoerSelector: function() {
      this.toggleProperty('showDoerSelector');
    },
    toggleComplete: function() {
      var conversation = this.get('content');
      conversation.set('done', !conversation.get('done'));
      conversation.saveRecord().then(function() {
        conversation.loadEvents(true);
      }.bind(this));
    },
    toggleMuted: function() {
      var conversation = this.get('content');
      conversation.set('muted', !conversation.get('muted'));
      conversation.saveRecord();
    }
  }
});
