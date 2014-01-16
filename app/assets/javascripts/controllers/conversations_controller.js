// This is a base class. We should never actually endup here
Covered.ConversationsController = Ember.ArrayController.extend({
  needs: ['organization'],
  organization: Ember.computed.alias('controllers.organization').readOnly(),

  mode: 'conversations-mode', // conversations-mode | tasks-mode | muted-mode

  conversationsMode: function() { return this.get('mode') == 'conversations-mode'; }.property('mode'),
  tasksMode:         function() { return this.get('mode') == 'tasks-mode';         }.property('mode'),
  mutedMode:         function() { return this.get('mode') == 'muted-mode';         }.property('mode'),

  actions: {
    showConversations: function() {
      this.set('mode', 'conversations-mode');
    },
    showTasks: function() {
      this.set('mode', 'tasks-mode');
    },
    showMuted: function() {
      this.set('mode', 'muted-mode');
    },
    toggleSeach: function() {
      this.toggleProperty('showSearch');
    }
  }
});
