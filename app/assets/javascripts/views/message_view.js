Covered.MessageView = Ember.View.extend({
  templateName: 'message',
  tagName: 'li',
  classNames: 'message',
  showQuotedText: false,

  anchor: function() {
    return "message-" + this.get('context').get('id');
  }.property('id'),

  actions: {
    toggleQuotedText: function() {
      this.set('showQuotedText', !this.get('showQuotedText'));
    }
  }
});
