// This is a base class. We should never actually endup here
Covered.ConversationsController = Ember.ArrayController.extend({
  needs: ['organization'],
  organization: Ember.computed.alias('controllers.organization').readOnly(),

  mode: 'conversations-mode', // conversations-mode | tasks-mode | muted-mode
  taskMode: 'my-tasks-mode', // my-tasks-mode | all-tasks-mode

  conversationsMode: function() { return this.get('mode') == 'conversations-mode'; }.property('mode'),
  tasksMode:         function() { return this.get('mode') == 'tasks-mode';         }.property('mode'),
  mutedMode:         function() { return this.get('mode') == 'muted-mode';         }.property('mode'),

  myTasksMode:  function() { return this.get('taskMode') == 'my-tasks-mode';  }.property('taskMode'),
  allTasksMode: function() { return this.get('taskMode') == 'all-tasks-mode'; }.property('taskMode'),


  showDone: false,
  prioritizing: false,

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
