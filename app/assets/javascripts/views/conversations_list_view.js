Covered.ConversationsListView = Ember.View.extend({
  templateName: 'conversations_list',
  tagName: 'div',

  type: null, // my | ungrouped | group

  group:         Ember.computed.alias('parentView.context.group.model').readOnly(),

  myConversations:        function() { return this.get('type') == 'my';        }.property('type'),
  ungroupedConversations: function() { return this.get('type') == 'ungrouped'; }.property('type'),
  groupConversations:     function() { return this.get('type') == 'group';     }.property('type'),

  conversations: Ember.computed.alias('context').readOnly(),

});
