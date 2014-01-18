//= require ./conversations_controller

Covered.UngroupedConversationsController = Covered.ConversationsController.extend({

  fetchNotMutedConversations: function() {
    return Covered.Conversation.ungroupedNotMutedConversations(this.get('organization'));
  },
  fetchMutedConversations: function() {
    return Covered.Conversation.ungroupedMutedConversations(this.get('organization'));
  },
  fetchAllTasks: function() {
    return Covered.Conversation.ungroupedAllTask(this.get('organization'));
  },
  fetchDoingTasks: function() {
    return Covered.Conversation.ungroupedDoingTasks(this.get('organization'));
  },

});
