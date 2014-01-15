Covered.ResizeableTextArea = Ember.TextArea.extend({
  keyDown: function(e) {
    var textarea = e.currentTarget;
    $(textarea).css('height', Math.max(textarea.scrollHeight, 208) + "px");
  }
});
