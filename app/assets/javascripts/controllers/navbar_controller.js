Covered.NavbarController = Ember.Controller.extend(Covered.CurrentUserMixin, {
  needs: ['organization', 'compose', 'conversation'],

  focus:           Ember.computed.alias('controllers.organization.focus'),
  newConversation: Ember.computed.alias('controllers.compose').readOnly(),
  conversation:    Ember.computed.alias('controllers.conversation').readOnly(),

  group: null,
  composeTarget: null,
  composing: false,

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
      this.get('conversation').send('toggleComplete');
    },
    toggleMuted: function() {
      this.get('conversation').send('toggleMuted');
    },
    toggleDoerSelector: function() {
      this.get('controllers.conversation').send('toggleDoerSelector');
    }
  }

});
