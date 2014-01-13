Covered.NavbarController = Ember.Controller.extend({
  needs: ['application'],
  currentUser: Ember.computed.alias('controllers.application.currentUser'),
  currentPath: Ember.computed.alias('controllers.application.currentPath'),

  organization: null,
  group: null,
  conversation: null,
  composeTarget: null,
  composing: false,

  navbarStyle: function() {
    var color = this.get('group.color');
    return color ? "background-color: "+color+";" : '';
  }.property('group.color'),

  actions: {
    sendMessage: function() {
      this.get('controllers.compose').send('sendMessage');
    },
    focusGroups: function() {
      this.controllerFor('organization').set('focus', 'groups');
    },
    focusConversations: function() {
      this.controllerFor('organization').set('focus', 'conversations');
      this.set('conversation', null);
    },
    goToCompose: function() {
      var composeTarget = this.get('composeTarget');
      if (composeTarget === 'my')        this.transitionToRoute('my_compose');
      if (composeTarget === 'ungrouped') this.transitionToRoute('ungrouped_compose');
      if (composeTarget === 'group')     this.transitionToRoute('group_compose');
    }
  }

});
