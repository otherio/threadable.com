// This is a base class. We should never actually endup here
Covered.ConversationsController = Ember.Controller.extend({
  needs: ['organization', 'conversations_state'],
  organization: Ember.computed.alias('controllers.organization').readOnly(),

  mode:          Ember.computed.alias('controllers.conversations_state.mode'),
  showDone:      Ember.computed.alias('controllers.conversations_state.showDone'),
  prioritizing:  Ember.computed.alias('controllers.conversations_state.prioritizing'),
  lastTasksMode: Ember.computed.alias('controllers.conversations_state.lastTasksMode').readOnly(),

  conversationsCacheKeyForMode: function(mode) {
    return mode;
  },

  conversationsCacheKey: function() {
    return this.conversationsCacheKeyForMode(this.get('mode'));
  }.property('mode'),

  conversationsCacheKeyChanged: function() {
    this.fetchConversations();
  }.observes('conversationsCacheKey').on('init'),

  fetchConversations: function() {
    var
      controller = this,
      mode = controller.get('mode'),
      conversationsCacheKey = this.get('conversationsCacheKey'),
      fetchMethod, promise;

    if (controller.get(conversationsCacheKey)){
      controller.set('loading', false);
      return;
    }
    controller.set('loading', true);

    fetchMethod = 'fetch'+mode.capitalize();
    promise = controller[fetchMethod]();
    controller.set(conversationsCacheKey, []);
    promise.then(function(conversations) {
      Ember.run(function() {
        controller.set(conversationsCacheKey, conversations);
        controller.set('loading', false);
      });
    });
  },

  showingNotMutedConversations: function() {return this.get('mode') === 'notMutedConversations';                         }.property('mode'),
  showingMutedConversations:    function() {return this.get('mode') === 'mutedConversations';                            }.property('mode'),
  showingTasks:                 function() {return this.get('mode') === 'allTasks' || this.get('mode') === 'doingTasks'; }.property('mode'),
  showingDoingTasks:            function() {return this.get('mode') === 'doingTasks';                                    }.property('mode'),
  showingAllTasks:              function() {return this.get('mode') === 'allTasks';                                      }.property('mode'),

  showingDoneTasks: Ember.computed.alias('showDone'),

  actions: {
    showNotMutedConversations: function() {
      this.set('mode', 'notMutedConversations');
    },
    showMutedConversations: function() {
      this.set('mode', 'mutedConversations');
    },
    showTasks: function() {
      this.set('mode', this.get('lastTasksMode') || 'allTasks');
    },
    showAllTasks: function() {
      this.set('mode', 'allTasks');
    },
    showDoingTasks: function() {
      this.set('mode', 'doingTasks');
    },
    toggleSeach: function() {
      this.toggleProperty('showSearch');
    },
    toggleShowDone: function() {
      this.toggleProperty('showDone');
    },
    togglePrioritizing: function() {
      this.toggleProperty('prioritizing');
    }
  },

  prependConversation: function(conversation) {
    var conversations;
    conversations = this.get(this.conversationsCacheKeyForMode('notMutedConversations'));
    if (conversations && conversations.unshiftObject) conversations.unshiftObject(conversation);
    if (!conversation.get('isTask')) return;
    conversations = this.get(this.conversationsCacheKeyForMode('allTasks'));
    if (conversations && conversations.unshiftObject) conversations.unshiftObject(conversation);
  }
});

// this controller saves the state across all ConversationsController subclasses
Covered.ConversationsStateController = Ember.Object.extend({

  // notMutedConversations | mutedConversations | allTasks | doingTasks
  mode:          sessionStorage.getItem('covered.conversations.state.mode')         || 'notMutedConversations',
  showDone:      sessionStorage.getItem('covered.conversations.state.showDone')     || false,
  prioritizing:  sessionStorage.getItem('covered.conversations.state.prioritizing') || false,
  lastTasksMode: sessionStorage.getItem('covered.conversations.state.lastTasksMode'),

  stateChanged: function() {
    var mode = this.get('mode');
    sessionStorage.setItem('covered.conversations.state.mode',         mode);
    sessionStorage.setItem('covered.conversations.state.showDone',     this.get('showDone'));
    sessionStorage.setItem('covered.conversations.state.prioritizing', this.get('prioritizing'));
    if (/tasks/i.test(mode)){
      this.set('lastTasksMode', mode);
      sessionStorage.setItem('covered.conversations.state.lastTasksMode', mode);
    }
  }.observes('mode', 'showDone', 'prioritizing').on('init')

});
