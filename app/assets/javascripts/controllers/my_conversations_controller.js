//= require ./conversations_controller

Covered.MyConversationsController = Covered.ConversationsController.extend({

  fetchNotMutedConversations: function() {
    return Covered.Conversation.myNotMutedConversations(this.get('organization'));
  },
  fetchMutedConversations: function() {
    return Covered.Conversation.myMutedConversations(this.get('organization'));
  },
  fetchAllTasks: function() {
    return Covered.Conversation.myAllTask(this.get('organization'));
  },
  fetchDoingTasks: function() {
    return Covered.Conversation.myDoingTasks(this.get('organization'));
  },

});
