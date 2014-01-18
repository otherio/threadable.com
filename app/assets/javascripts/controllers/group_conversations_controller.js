//= require ./conversations_controller

Covered.GroupConversationsController = Covered.ConversationsController.extend({
  needs: ['group'],
  group: Ember.computed.alias('controllers.group').readOnly(),

  conversationsCacheKeyForMode: function(mode) {
    return this.get('group.slug')+'-'+mode;
  },

  conversationsCacheKey: function() { return this._super(); }.property('mode', 'group.slug'),

  fetchNotMutedConversations: function() {
    return Covered.Conversation.groupNotMutedConversations(this.get('organization'), this.get('group.slug'));
  },
  fetchMutedConversations: function() {
    return Covered.Conversation.groupMutedConversations(this.get('organization'), this.get('group.slug'));
  },
  fetchAllTasks: function() {
    return Covered.Conversation.groupAllTask(this.get('organization'), this.get('group.slug'));
  },
  fetchDoingTasks: function() {
    return Covered.Conversation.groupDoingTasks(this.get('organization'), this.get('group.slug'));
  },
});
