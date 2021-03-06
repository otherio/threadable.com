Threadable.TopbarController = Ember.Controller.extend(Threadable.CurrentUserMixin, Threadable.RoutesMixin, {
  needs: ['organization', 'sidebar', 'conversations', 'conversation', 'compose'],

  focus:           Ember.computed.alias('controllers.organization.focus'),
  newConversation: Ember.computed.alias('controllers.compose').readOnly(),
  conversation:    Ember.computed.alias('controllers.conversation').readOnly(),
  conversations:   Ember.computed.alias('controllers.conversations').readOnly(),

  group: null,
  composing: false,
  conversationDetail: false,

  showingConversationsListControls: false,

  subjectTag: function() {
    return this.get('group.subjectTag') || this.get('organization.subjectTag');
  }.property('organization.subjectTag', 'group.subjectTag'),

  topbarStyle: function() {
    var color = this.get('group.color');
    return color ? "background-color: "+color+";" : '';
  }.property('group.color'),

  showComposing: function() {
    return this.get('composing') && this.get('focus') == 'conversation';
  }.property('composing', 'focus'),

  showConversation: function() {
    return !this.get('composing') && !this.get('conversationDetail') && this.get('focus') == 'conversation';
  }.property('composing', 'conversationDetail', 'focus'),

  showConversationDetail: function() {
    return !this.get('composing') && this.get('conversationDetail') && this.get('focus') == 'conversation';
  }.property('composing', 'conversationDetail', 'focus'),

  showOrganization: function() {
    return !this.get('showComposing') && !this.get('showConversationDetail') && !this.get('showConversation');
  }.property('showComposing', 'showConversationDetail', 'showConversation'),

  actions: {
    openSidebar: function() {
      this.get('controllers.sidebar').send('openSidebar');
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
    toggleFollowed: function() {
      this.get('conversation').send('toggleFollowed');
    },
    trash: function() {
      this.get('conversation').send('trash');
    },
    unTrash: function() {
      this.get('conversation').send('unTrash');
    },
    toggleDoerSelector: function() {
      this.get('controllers.conversation').send('toggleDoerSelector');
    },
    toggleConversationsListControls: function() {
      this.toggleProperty('showingConversationsListControls');
    }
  }

});
