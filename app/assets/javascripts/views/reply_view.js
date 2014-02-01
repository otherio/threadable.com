Covered.ReplyView = Ember.View.extend({
  tagName: 'div',
  classNames: 'reply well',

  didInsertElement: function() {
    $('.reply-content').focus(function() {
      $('.conversation-show').scrollTop($('.conversation-show')[0].scrollHeight);
    });
  }
});
