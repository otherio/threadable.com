Covered.ConversationsListView = Ember.View.extend({
  templateName: 'conversations_list',
  tagName: 'div',
  classNames: 'conversations-list',

  type: null, // my | ungrouped | group

  mode: Ember.computed.alias('context.mode'),
  group: Ember.computed.alias('parentView.context.group.model').readOnly(),
  // conversations: Ember.computed.alias('context').readOnly(),

  myConversations:        function() { return this.get('type') == 'my';        }.property('type'),
  ungroupedConversations: function() { return this.get('type') == 'ungrouped'; }.property('type'),
  groupConversations:     function() { return this.get('type') == 'group';     }.property('type'),

  listTypeClassname: function() {
    var mode = this.get('mode');
    if (/conversations/i.test(mode)) return 'list-of-conversations';
    if (/task/i.test(mode))          return 'list-of-tasks';
  }.property('mode'),

  conversations: function() {
    var conversationsCacheKey = this.get('context.conversationsCacheKey');
    return this.get('context').get(conversationsCacheKey);
  }.property('context.conversationsCacheKey', 'context.loading', 'type')

});
