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

  listOfConversations: function() { return /conversations/i.test(this.get('mode')); }.property('mode'),
  listOfTasks:         function() { return         /tasks/i.test(this.get('mode')); }.property('mode'),

  listTypeClassname: function() {
    if (this.get('listOfConversations')) return 'list-of-conversations';
    if (this.get('listOfTasks'))         return 'list-of-tasks';
  }.property('listOfConversations', 'listOfTasks'),

  conversations: function() {
    var conversationsCacheKey = this.get('context.conversationsCacheKey');
    return this.get('context').get(conversationsCacheKey);
  }.property('context.conversationsCacheKey', 'context.loading', 'type')

});
