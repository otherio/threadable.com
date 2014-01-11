Covered.NavbarController = Ember.Controller.extend({
  needs: ['application', 'organization', 'group', 'conversation', 'compose'],
  currentUser:           Ember.computed.alias('controllers.application.currentUser'),
  currentOrganization:   Ember.computed.alias('controllers.organization'),
  currentConversation:   Ember.computed.alias('controllers.conversation'),
  currentGroup:          Ember.computed.alias('controllers.group'),
  composing:             Ember.computed.alias('controllers.compose.composing'),
  composingTask:         Ember.computed.alias('controllers.compose.composingTask'),
  composingConversation: Ember.computed.alias('controllers.compose.composingConversation'),

  actions: {
    sendMessage: function() {
      this.get('controllers.compose').send('sendMessage');
    },
    focusGroups: function() {
      this.get('currentOrganization').set('focus', 'groups');
    },
    focusConversations: function() {
      this.get('currentOrganization').set('focus', 'conversations');
    }
  }

});
