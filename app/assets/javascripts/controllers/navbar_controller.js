Covered.NavbarController = Ember.Controller.extend(Covered.CurrentUserMixin, Covered.RoutesMixin, {
  needs: ['organization', 'conversations', 'compose', 'conversation'],

  focus:           Ember.computed.alias('controllers.organization.focus'),
  newConversation: Ember.computed.alias('controllers.compose').readOnly(),
  conversation:    Ember.computed.alias('controllers.conversation').readOnly(),
  conversations:   Ember.computed.alias('controllers.conversations').readOnly(),

  group: null,
  composing: false,

  showingConversationsListControls: false,

  navbarStyle: function() {
    var color = this.get('group.color');
    return color ? "background-color: "+color+";" : '';
  }.property('group.color'),

  showComposing: function() {
    return this.get('composing') && this.get('focus') == 'conversation';
  }.property('composing', 'focus'),

  showConversation: function() {
    return !this.get('composing') && this.get('focus') == 'conversation';
  }.property('composing', 'focus'),

  showOrganization: function() {
    return !this.get('showComposing') && !this.get('showConversation');
  }.property('showComposing', 'showConversation'),

  actions: {
    focusGroups: function() {
      this.set('focus', 'groups');
    },
    focusConversations: function() {
      this.set('focus', 'conversations');
      this.set('composing', false);
      this.send('transitionUp');
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
      this.get('conversation').send('toggleComplete');
    },
    toggleMuted: function() {
      this.get('conversation').send('toggleMuted');
    },
    toggleDoerSelector: function() {
      this.get('controllers.conversation').send('toggleDoerSelector');
    },
    toggleConversationsListControls: function() {
      this.toggleProperty('showingConversationsListControls');
    }
  }

});
