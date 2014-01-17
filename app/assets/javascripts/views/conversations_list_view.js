Covered.ConversationsListView = Ember.View.extend({
  templateName: 'conversations_list',
  tagName: 'div',
  classNames: 'conversations-list',

  type: null, // my | ungrouped | group

  group:         Ember.computed.alias('parentView.context.group.model').readOnly(),
  conversations: Ember.computed.alias('context').readOnly(),

  myConversations:        function() { return this.get('type') == 'my';        }.property('type'),
  ungroupedConversations: function() { return this.get('type') == 'ungrouped'; }.property('type'),
  groupConversations:     function() { return this.get('type') == 'group';     }.property('type'),


  // this is crazy but I don't know a better way - Jared

  detectNoConversations: function() {
    this.updateNoConversations();
  }.observes('conversations.@each', 'context.mode'),

  didInsertElement: function() {
    this.updateNoConversations();
    return this._super();
  },

  updateNoConversations: function() {
    setTimeout(function() {
      Ember.run(function() {
        var wrapper = $('.conversations-list > .wrapper');
        if (wrapper.find('.all-conversations .conversation:visible').length === 0){
          wrapper.addClass('show-no-conversations');
        }else{
          wrapper.removeClass('show-no-conversations');
        }
        if (wrapper.find('.done-tasks .conversation:visible').length === 0){
          wrapper.addClass('show-no-done-tasks');
        }else{
          wrapper.removeClass('show-no-done-tasks');
        }
      });
    });
  }

  // /crazy

});
