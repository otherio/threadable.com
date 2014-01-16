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
  }.property('type', 'mode', 'taskMode'),

  detectNoConversations: function() {
    this.updateNoConversations();
  }.observes('conversations.@each', 'context.mode', 'context.taskMode', 'context.showDone'),

  didInsertElement: function() {
    this.updateNoConversations();
    return this._super();
  },

  // this is crazy but I don't know a better way - Jared
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

});
