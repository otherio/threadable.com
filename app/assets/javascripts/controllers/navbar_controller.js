Covered.NavbarController = Ember.Controller.extend({
  needs: ['application', 'organization', 'group', 'conversation', 'compose'],
  currentUser:         Ember.computed.alias('controllers.application.currentUser'),
  currentOrganization: Ember.computed.alias('controllers.organization'),
  currentConversation: Ember.computed.alias('controllers.conversation'),
  currentGroup:        Ember.computed.alias('controllers.group'),
  composing:           Ember.computed.alias('controllers.application.composing'),

  composingTask: function() {
    return this.get('composing') == 'task';
  }.property('composing'),

  composingConversation: function() {
    return this.get('composing') == 'conversation';
  }.property('composing'),

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
