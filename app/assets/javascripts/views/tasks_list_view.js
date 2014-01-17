Covered.TasksListView = Covered.ConversationsListView.extend({
  templateName: 'tasks_list',
  tagName: 'div',
  classNames: 'conversations-list tasks-list',

  doneTasks: function() {
    return this.get('conversations').filter(function(conversation) {
      return conversation.get('isTask') && conversation.get('isDone');
    });
  }.property('conversations'),

  noDoneTasksMessage: function() {
    return 'no done tasks: ';
  }.property('type', 'context.mode', 'context.taskMode'),

  noConversationsMessage: function() {
    return this.get('context.taskMode') ? 'no tasks' : 'no conversations';
  }.property('type', 'mode', 'taskMode')

});
