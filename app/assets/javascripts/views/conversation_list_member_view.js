Covered.ConversationListMemberView = Ember.View.extend({
  templateName: 'conversations/conversation',
  tagName: 'div',

  conversation: Ember.computed.alias('context').readOnly(),
  group:        Ember.computed.alias('parentView.context.group.model').readOnly(),

  groups: function() {
    var groups = this.get('conversation.groups');
    var currentGroup = this.get('group');
    return groups.filter(function(group) {
      return group !== currentGroup;
    });
  }.property('conversation.groups')
});
