Covered.GroupsController = Ember.ArrayController.extend(Covered.CurrentUserMixin, {
  needs: ['organization', 'application', 'conversation'],
  organization: Ember.computed.alias('controllers.organization'),
  currentPath: Ember.computed.alias('controllers.application.currentPath').readOnly(),
  currentConversation: Ember.computed.alias('controllers.conversation.model').readOnly(),

  composing: function() {
    var currentPath = this.get('currentPath')
    return currentPath && currentPath.includes('.compose');
  }.property('currentPath'),

  myConversationsRoute: function() {
    return this.get('composing') ? 'compose_my_conversation' : 'my_conversations';
  }.property('currentPath'),

  ungroupedConversationsRoute: function() {
    return this.get('composing') ? 'compose_ungrouped_conversation' : 'ungrouped_conversations';
  }.property('currentPath'),

  groupConversationsRoute: function() {
    return this.get('composing') ? 'compose_group_conversation' : 'group_conversations';
  }.property('currentPath'),


  actions: {
    signOut: function() {
      this.signOut();
      this.transitionToRoute('index');
    },
    toggleSettings: function(){
      this.set('settingsVisible', !this.get('settingsVisible'));
    }
  }

});
