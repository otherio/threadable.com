Covered.ConversationsListView = Ember.View.extend({
  templateName: 'conversations_list',
  tagName: 'div',
  classNames: 'conversations-list',

  type: null, // my | ungrouped | group

  group:         Ember.computed.alias('parentView.context.group.model').readOnly(),
  conversations: Ember.computed.alias('context').readOnly(),

  myConversations:        function() { return this.get('type') == 'my';        }.property('type'),
  ungroupedConversations: function() { return this.get('type') == 'ungrouped'; }.property('type'),
  groupConversations:     function() { return this.get('type') == 'group';     }.property('type')

});
