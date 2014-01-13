Covered.NavbarController = Ember.Controller.extend({
  needs: ['application', 'organization'],
  currentUser: Ember.computed.alias('controllers.application.currentUser').readOnly(),
  currentPath: Ember.computed.alias('controllers.application.currentPath').readOnly(),

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
      this.get('controllers.organization').set('focus', 'groups');
    },
    focusConversations: function() {
      // this.set('conversation', null);
      // this.get('controllers.organization').set('focus', 'conversations');
      this.send('transitionUp');
    },
    goToCompose: function() {
      // this.send('goToCompose');
      return true;
    }
  }

});
