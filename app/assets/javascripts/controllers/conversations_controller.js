// This is a base class. We should never actually endup here
Covered.ConversationsController = Ember.ArrayController.extend({
  needs: ['organization', 'conversations_state'],
  organization: Ember.computed.alias('controllers.organization').readOnly(),


  mode:         Ember.computed.alias('controllers.conversations_state.mode'),
  taskMode:     Ember.computed.alias('controllers.conversations_state.taskMode'),
  showDone:     Ember.computed.alias('controllers.conversations_state.showDone'),
  prioritizing: Ember.computed.alias('controllers.conversations_state.prioritizing'),

  conversationsMode: function() { return this.get('mode') == 'conversations-mode'; }.property('mode'),
  tasksMode:         function() { return this.get('mode') == 'tasks-mode';         }.property('mode'),
  mutedMode:         function() { return this.get('mode') == 'muted-mode';         }.property('mode'),

  myTasksMode:  function() { return this.get('taskMode') == 'my-tasks-mode';  }.property('taskMode'),
  allTasksMode: function() { return this.get('taskMode') == 'all-tasks-mode'; }.property('taskMode'),

  conversationsFindOptions: function() {
    return {};
  },

  tasks: function() {
    console.debug('RECALCING TASKS FOR MODE: ', this.get('mode'));
    var
      organization  = this.get('organization.model'),
      conversations = Covered.Conversation.find(this.conversationsFindOptions());

    if (!organization) debugger;

    conversations.on('didLoad', function(conversations){
      console.log(conversations.toArray());
      conversations.forEach(function(conversation){
        conversation.set('organization', organization);
      });
    });
    return conversations;
  }.property('organization.model'),


  actions: {
    conversationsMode: function() {
      this.set('mode', 'conversations-mode');
    },
    tasksMode: function() {
      this.set('mode', 'tasks-mode');
    },
    mutedMode: function() {
      this.set('mode', 'muted-mode');
    },
    toggleSeach: function() {
      this.toggleProperty('showSearch');
    },

    myTasksMode: function() {
      this.set('taskMode','my-tasks-mode');
    },
    allTasksMode: function() {
      this.set('taskMode','all-tasks-mode');
    },
    showDone: function() {
      this.toggleProperty('showDone');
    },
    togglePrioritizing: function() {
      this.toggleProperty('prioritizing');
    }
  }
});

// this controller saves the state across all ConversationsController subclasses
Covered.ConversationsStateController = Ember.Object.extend({
  mode:         'conversations-mode', // conversations-mode | tasks-mode | muted-mode
  taskMode:     'all-tasks-mode', // my-tasks-mode | all-tasks-mode
  showDone:     false,
  prioritizing: false,
});
