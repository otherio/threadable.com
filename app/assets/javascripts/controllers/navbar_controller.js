Covered.NavbarController = Ember.Controller.extend({
  needs: ['application', 'organization', 'compose', 'conversation'],
  currentUser:     Ember.computed.alias('controllers.application.currentUser').readOnly(),
  currentPath:     Ember.computed.alias('controllers.application.currentPath').readOnly(),
  newConversation: Ember.computed.alias('controllers.compose').readOnly(),
  task:            Ember.computed.alias('controllers.conversation.task').readOnly(),
  taskDone:        Ember.computed.alias('controllers.conversation.done').readOnly(),

  group: null,
  conversation: null,
  composeTarget: null,
  composing: false,

  navbarStyle: function() {
    var color = this.get('group.color');
    return color ? "background-color: "+color+";" : '';
  }.property('group.color'),

  actions: {
    focusGroups: function() {
      this.get('controllers.organization').set('focus', 'groups');
    },
    focusConversations: function() {
      this.set('composing', false);
      this.send('transitionUp');
    },
    goToCompose: function() {
      // this.send('goToCompose');
      return true;
    },
    composeTask: function() {
      this.get('newConversation').send('composeTask');
    },
    composeConversation: function() {
      this.get('newConversation').send('composeConversation');
    },
    sendMessage: function() {
      this.get('newConversation').send('sendMessage');
    },
    toggleComplete: function() {
      this.get('controllers.conversation').send('toggleComplete');
    }
  }

});
