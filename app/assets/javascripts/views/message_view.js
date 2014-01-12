Covered.MessageView = Ember.View.extend({
  templateName: 'message',
  tagName: 'li',
  classNames: 'message',
  showQuotedText: false,

  actions: {
    toggleQuotedText: function() {
      this.set('showQuotedText', !this.get('showQuotedText'));
    }
  }
});
